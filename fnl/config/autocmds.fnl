(require-macros :macros)

(augroup! :my-autocmds
          ; Define Ex helpers for thyme, it's recommended to do it in `VimEnter`
          (au! :VimEnter #(: (require :thyme) :setup)))
