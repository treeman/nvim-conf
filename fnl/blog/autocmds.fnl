(require-macros :macros)

(local path (require :blog.path))

(local autocmd-pattern (.. path.blog_path "*.dj"))

(local debounce-ms 150)
(local change-timers {})
(local attached-buffers {})

(fn buffer-text [bufnr]
  (vim.fn.join (vim.api.nvim_buf_get_lines bufnr 0 -1 false) "\n"))

(fn cancel-timer [bufnr]
  (local t (. change-timers bufnr))
  (when t
    (t:stop)
    (t:close)
    (tset change-timers bufnr nil)))

(fn schedule-did-change [bufnr]
  (cancel-timer bufnr)
  (local t (vim.uv.new_timer))
  (tset change-timers bufnr t)
  (t:start debounce-ms 0
           (vim.schedule_wrap (fn []
                                ;; Only clear our slot if the registered timer is still us; a
                                ;; concurrent reschedule may have replaced it.
                                (when (= (. change-timers bufnr) t)
                                  (tset change-timers bufnr nil))
                                (when (not (t:is_closing)) (t:close))
                                (when (vim.api.nvim_buf_is_valid bufnr)
                                  (m blog.server cast
                                     {:id "DidChange"
                                      :path (vim.api.nvim_buf_get_name bufnr)
                                      :text (buffer-text bufnr)}))))))

;; on_lines fires for every buffer modification, including changes driven
;; by completion plugins. TextChangedI/TextChangedP are unreliable while
;; completion popups are active, so we use the same mechanism the built-in
;; LSP client uses for textDocument/didChange.
(fn attach-buffer [bufnr]
  (when (not (. attached-buffers bufnr))
    (tset attached-buffers bufnr true)
    (vim.api.nvim_buf_attach bufnr false
                             {:on_lines (fn [_event b]
                                          (schedule-did-change b)
                                          ;; nil/false: stay attached.
                                          false)
                              :on_detach (fn [_event b]
                                           (tset attached-buffers b nil))})))

;; After a (re)connect, re-establish overlays on the server for every
;; buffer we currently track. Empty on the very first connect (no buffer
;; has been attached yet); only does real work on reconnect.
((. (require :blog.server) :on_connect)
 (fn []
   (each [bufnr _ (pairs attached-buffers)]
     (when (vim.api.nvim_buf_is_valid bufnr)
       (m blog.server cast
          {:id "DidOpen"
           :path (vim.api.nvim_buf_get_name bufnr)
           :text (buffer-text bufnr)})))))

(augroup! :blog (au! [:BufReadPost :BufNewFile] [autocmd-pattern]
                     (fn [opts]
                       (tset (. vim.b 0) :blog_file true)
                       (m blog.server establish_connection true)
                       (m blog.server cast
                          {:id "DidOpen"
                           :path (vim.api.nvim_buf_get_name opts.buf)
                           :text (buffer-text opts.buf)})
                       (attach-buffer opts.buf)
                       (bmap! :n "<localleader>d"
                              #(m blog.interaction goto_def)
                              {:desc "Goto definition"})
                       (bmap! :n "<localleader>h"
                              (. (require :blog.interaction) :hover)
                              {:desc "Hover help"})
                       false))
          (au! :BufUnload [autocmd-pattern]
               (fn [opts]
                 (cancel-timer opts.buf)
                 (m blog.server cast
                    {:id "DidClose" :path (vim.api.nvim_buf_get_name opts.buf)})))
          (au! :CursorMoved [autocmd-pattern]
               #(do
                  (local pos (vim.api.nvim_win_get_cursor 0))
                  (m blog.server cast
                     {:id "CursorMoved"
                      :linenum (. pos 1)
                      :linecount (vim.fn.line "$")
                      :column (. pos 2)
                      :path (vim.fn.expand "%:p")})
                  (when (. vim.b 0 :blog_float_win)
                    (vim.api.nvim_win_close (. vim.b 0 :blog_float_win) true)
                    (tset (. vim.b 0) :blog_float_win nil)))))
