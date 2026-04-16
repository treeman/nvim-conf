(require-macros :macros)

(augroup! :my-autocmds ;; Not sure how to hide this from certain file buffers?
          ;; Maybe we can query for the filetype of buffer, and then exclude some things?
          ;; This ignores the dashboard at least, which maybe is good enough?
          (au! [:VimEnter :WinEnter :BufWinEnter]
               #(do
                  (when (> (string.len $1.file) 0)
                    (let! :opt_local :cursorline true))
                  false))
          (au! :WinLeave #(do
                            (let! :opt_local :cursorline false)
                            false))
          (au! :TextYankPost
               #(when (and (= vim.v.event.operator :y)
                           (= vim.bo.buftype :terminal))
                  (let [reg (if (= vim.v.event.regname "") "\""
                                vim.v.event.regname)
                        text (vim.fn.getreg reg)
                        step1 (text:gsub "[ \t]+\n" "\n")
                        trimmed (step1:gsub "[ \t]+$" "")]
                    (vim.fn.setreg reg trimmed vim.v.event.regtype))))
          ;; https://github.com/stevearc/oil.nvim/issues/87
          (au! :User [:OilEnter]
               (vim.schedule_wrap (λ [args]
                                    (local oil (require :oil))
                                    (when (and (= (vim.api.nvim_get_current_buf)
                                                  args.data.buf)
                                               (oil.get_cursor_entry))
                                      (oil.open_preview)))))
          (au! :FileType [:htmldjango] "set ft=html"))
