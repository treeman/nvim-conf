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

(fn gen-message-id []
  (local message-id (or vim.g.blog_message_id 0))
  (set vim.g.blog_message_id (+ message-id 1))
  message-id)

(fn call [msg cb]
  (when (not (is-connected))
    (lua "return nil"))
  (nio.run (λ []
             ;; Create a unique message id for the call
             (local msg-id (gen-message-id))
             (tset msg :message_id msg-id)
             (send-msg msg)
             (local msg-id-s (tostring msg-id))
             ;; Wait for response. 1 sec should be more than enough, otherwise we bail.
             (var attempt 0)
             (while (< attempt 100)
               (when vim.g.blog_messages
                 (local reply (. vim.g.blog_messages msg-id-s))
                 (when reply
                   (tset vim.g.blog_messages msg-id-s nil)
                   (lua "return reply")))
               (set attempt (+ attempt 1))
               (nio.sleep 10))
             ;; Response timed out
             false) (λ [success reply]
                                 (when (and success reply)
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

(var reply-buffer nil)

(fn handle-reply [data]
  (when (and (= (length data) 1) (= (. data 1) ""))
    (close-connection)
    (lua "return"))
  (when (= (length data) 0)
    (log.warn "Empty data received")
    (lua "return"))
  (local last (string.sub (. data 1) -1))
  (if (= last "\006")
      (do
        (local input (string.sub (. data 1) 1 -2))
        (local all-data (if (= reply-buffer nil)
                            input
                            (let [result (.. reply-buffer input)]
                              (set reply-buffer nil)
                              result)))
        (local reply (vim.fn.json_decode all-data))
        (when (not reply) (lua "return"))
        (if (. reply :message_id)
            (let [message-id (tostring (. reply :message_id))
                  messages (or vim.g.blog_messages {})]
              (tset messages message-id reply)
              (set vim.g.blog_messages messages))
            (= reply.id "Diagnostics")
            (diagnostics.add_diagnostics reply.diagnostics)
            (log.debug "Unknown message:" (vim.inspect reply))))
      (do
        ;; We've got more data, store and handle it later
        (if (= reply-buffer nil)
            (set reply-buffer (. data 1))
            (set reply-buffer (.. reply-buffer (. data 1)))))))

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
