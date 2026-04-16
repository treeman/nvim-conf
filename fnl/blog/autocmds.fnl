(require-macros :macros)

(local path (require :blog.path))

(local autocmd-pattern (.. path.blog_path "*.dj"))

(augroup! :blog (au! [:BufRead :BufNewFile] [autocmd-pattern]
                     (fn [_opts]
                       (tset (. vim.b 0) :blog_file true)
                       (m blog.server establish_connection true)
                       ((. (require :blog.diagnostics)
                           :request_diagnostics_curr_buf))
                       (bmap! :n "<localleader>d"
                              #(m blog.interaction goto_def)
                              {:desc "Goto definition"})
                       (bmap! :n "<localleader>h"
                              (. (require :blog.interaction) :hover)
                              {:desc "Hover help"})
                       false))
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
