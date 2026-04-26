(local diagnostics (require :blog.diagnostics))
(local log ((. (require :plenary.log) :new) {:plugin :blog :level :error}))
(local nio (require :nio))
(local path (require :blog.path))

(fn is-connected []
  (not= vim.g.blog_conn nil))

(fn is-blog-buf []
  (. vim.b 0 :blog_file))

(fn is-buf-connected []
  (and (is-connected) (is-blog-buf)))

(fn has-server []
  (not= vim.g.blog_job_id nil))

(fn blog-status []
  (if (not (. vim.b 0 :blog_file)) ""
      (let [connected (is-connected)
            server (has-server)]
        (if (and server connected) "s"
            server "Server but not connected"
            connected "c"
            ""))))

;; Event handling

(fn send-msg [msg]
  (local conn vim.g.blog_conn)
  (if conn
      (do
        (vim.fn.chansend conn (vim.fn.json_encode msg))
        ;; Watcher tries to read lines so we need to terminate the message with a newline
        (vim.fn.chansend conn "\n"))
      (log.error "Trying to send a message without being connected")))

(local pending {})
(var next-message-id 0)
(local call-timeout-ms 5000)

(fn gen-message-id []
  (set next-message-id (+ next-message-id 1))
  next-message-id)

(fn call [msg cb]
  (when (not (is-connected))
    (lua "return nil"))
  (local msg-id (gen-message-id))
  (tset msg :message_id msg-id)
  (local future (nio.control.future))
  (tset pending msg-id future)
  (nio.run
    (fn []
      (send-msg msg)
      ;; Time the request out so the future is always resolved.
      (nio.run
        (fn []
          (nio.sleep call-timeout-ms)
          (when (not (future.is_set))
            (future.set_error "timeout"))))
      (local (ok reply) (pcall future.wait))
      (tset pending msg-id nil)
      (when (and ok reply)
        (cb reply)))))

(fn cast [msg]
  (when (not (is-connected))
    (lua "return"))
  (nio.run (fn [] (send-msg msg))))

;; Server management

(fn start-server []
  (when (not= vim.g.blog_job_id nil) (lua "return"))
  (local buf (vim.api.nvim_create_buf true true))
  (set vim.g.blog_job_bufnr buf)
  (vim.api.nvim_buf_call buf
                         (fn []
                           (set vim.g.blog_job_id
                                (vim.fn.termopen "./blog watch"
                                                 {:cwd path.blog_path})))))

(fn stop-server []
  (when (= vim.g.blog_job_id nil) (lua "return"))
  (vim.fn.jobstop vim.g.blog_job_id)
  (vim.api.nvim_buf_delete vim.g.blog_job_bufnr {:force true})
  (set vim.g.blog_job_bufnr nil)
  (set vim.g.blog_job_id nil))

;; Server connection management

(fn close-connection []
  (when (= vim.g.blog_conn nil) (lua "return"))
  (vim.fn.chanclose vim.g.blog_conn)
  (set vim.g.blog_conn nil))

(var reply-buffer "")

(fn process-reply [json-str]
  (local reply (vim.fn.json_decode json-str))
  (when (not reply) (lua "return"))
  (if (. reply :message_id)
      (let [future (. pending (. reply :message_id))]
        (when (and future (not (future.is_set)))
          (future.set reply)))
      (= reply.id "Diagnostics")
      (diagnostics.add_diagnostics reply.diagnostics)
      (log.debug "Unknown message:" (vim.inspect reply))))

(fn handle-reply [data]
  (when (and (= (length data) 1) (= (. data 1) ""))
    (close-connection)
    (lua "return"))
  (when (= (length data) 0)
    (log.warn "Empty data received")
    (lua "return"))
  ;; `data` is the raw byte stream split on \n by Neovim's channel callback.
  ;; Rejoin to recover bytes, then process each \n-terminated message.
  (set reply-buffer (.. reply-buffer (table.concat data "\n")))
  (var newline-pos (string.find reply-buffer "\n" 1 true))
  (while newline-pos
    (local message (string.sub reply-buffer 1 (- newline-pos 1)))
    (set reply-buffer (string.sub reply-buffer (+ newline-pos 1)))
    (when (not= message "")
      (process-reply message))
    (set newline-pos (string.find reply-buffer "\n" 1 true))))

(fn try-connect []
  (when vim.g.blog_conn
    (lua "return true"))
  (local (status err)
         (pcall (fn []
                  (set vim.g.blog_conn
                       (vim.fn.sockconnect :tcp "127.0.0.1:8082"
                                           {:on_data (fn [_ data _]
                                                       (nio.run (fn []
                                                                  (handle-reply data))))})))))
  (if status
      (do
        (diagnostics.request_diagnostics_curr_buf)
        true)
      (do
        (log.debug "Connection error:" (vim.inspect err))
        false)))

(fn establish-connection [ensure-server-started]
  (local ensure-server-started (or ensure-server-started true))
  ;; To figure out if we have a server started somewhere
  ;; (from another Neovim instance or from the command line)
  ;; we first try to connect to it.
  (when (try-connect) (lua "return"))
  ;; If that fails, try to start the blog server.
  (when ensure-server-started
    (start-server))
  ;; Then try to reconnect, via a task to not block the UI.
  (nio.run (fn []
             (var attempt 0)
             (while (< attempt 10)
               (set attempt (+ attempt 1))
               (nio.sleep 1000)
               (when (try-connect)
                 (lua "return"))))))

(fn start []
  (start-server)
  (establish-connection false))

(fn stop []
  (close-connection)
  (stop-server))

(fn restart []
  (stop)
  (start))

(fn reconnect []
  (close-connection)
  (try-connect))

;; Define export here because lib loading sometimes makes these nil...?
{:is_buf_connected is-buf-connected
 :is_blog_buf is-blog-buf
 :is_connected is-connected
 :has_server has-server
 : call
 : cast
 :blog_status blog-status
 : start
 :handle_reply handle-reply
 :try_connect try-connect
 :establish_connection establish-connection
 : stop
 : restart
 : reconnect}
