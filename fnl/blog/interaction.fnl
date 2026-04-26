(local content (require :blog.content))
(local server (require :blog.server))

(local M {})

(fn M.goto_def []
  (local pos (vim.api.nvim_win_get_cursor 0))
  (server.call {:id "GotoDef"
                :linenum (- (. pos 1) 1)
                :column (. pos 2)
                :path (vim.fn.expand "%:p")}
               (fn [reply]
                 (when (or reply.path reply.linenum)
                   (vim.cmd ":normal m'"))
                 (when reply.path
                   (vim.cmd (.. ":e" reply.path)))
                 (when reply.linenum
                   (vim.api.nvim_win_set_cursor 0
                     [(+ reply.linenum 1) reply.column])))))

(fn M.hover []
  (content.cursor_info
    (fn [reply]
      (when reply.documentation
        (local docs (vim.split reply.documentation "\n"))
        (local buf (vim.api.nvim_create_buf false true))
        (vim.api.nvim_set_option_value :filetype :djot {:buf buf})
        (vim.api.nvim_buf_set_lines buf 0 -1 false docs)
        (local height (length docs))
        (var width 0)
        (each [_ line (ipairs docs)]
          (when (> (length line) width)
            (set width (length line))))
        (tset (. vim.b 0) :blog_float_win
          (vim.api.nvim_open_win buf false
            {:relative :cursor
             :width width
             :height height
             :col 0
             :row 1
             :focusable false
             :style :minimal
             :border :none}))))))

M
