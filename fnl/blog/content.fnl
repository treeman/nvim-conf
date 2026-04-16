(local helpers (require :util.helpers))
(local nio (require :nio))
(local server (require :blog.server))

(local M {})

(fn M.list_tags [cb]
  (server.call {:id "ListTags"} cb))

(fn M.extract_title [file-path]
  (local title
    (helpers.run_cmd {:cmd :rg
                      :args ["-INo" "^title = (.+)$" file-path]}))
  (when title
    (title:match "title = \"([^\"]+)\"")))

(fn M.list_markup_content [cb]
  (nio.run
    (fn []
      (local output
        (helpers.run_cmd {:cmd :cargo
                          :args [:run "-q" "--" "list-markup-content"]
                          :cwd "/home/tree/code/jonashietala"}))
      (when output
        (nio.scheduler)
        (local posts (vim.fn.json_decode output))
        (cb posts)))))

(fn M.cursor_info [cb]
  (local pos (vim.api.nvim_win_get_cursor 0))
  (server.call {:id "CursorInfo"
                :linenum (- (. pos 1) 1)
                :column (. pos 2)
                :path (vim.fn.expand "%:p")}
               cb))

M
