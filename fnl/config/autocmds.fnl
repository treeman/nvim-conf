(require-macros :macros)

(augroup! :my-autocmds
          ; Define Ex helpers for thyme, it's recommended to do it in `VimEnter`
          (au! :VimEnter #(: (require :thyme) :setup))
          ;; Not sure how to hide this from certain file buffers?
          ;; Maybe we can query for the filetype of buffer, and then exclude some things?
          ;; This ignores the dashboard at least, which maybe is good enough?
          (au! [:VimEnter :WinEnter :BufWinEnter]
               #(do
                  (when (> (string.len $1.file) 0)
                    (let! :opt_local :cursorline true))
                  false))
          (au! :WinLeave #(do
                            (let! :opt_local :cursorline false)
                            false)))
