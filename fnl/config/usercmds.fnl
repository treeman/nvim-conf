(require-macros :laurel.macros)

(command! :ToggleSpell #(set! :spell (not (vim.opt.spell:get))))
(command! :Rename #(: (require :snacks.rename) :rename_file))

(command! :FormatDisable
          #(if $1.bang
               (b! :disable_autoformat true)
               (g! :disable_autoformat true))
          {:desc "Re-enable autoformat-on-save" :bang true})

(command! "FormatEnable"
          (λ []
            (b! :disable_autoformat false)
            (g! :disable_autoformat false))
          {:desc "Re-enable autoformat-on-save" :bang true})

(command! :Format
          (λ [args]
            (local range
                   (when (not= args.count -1)
                     (local end_line (. (vim.api.nvim_buf_get_lines 0
                                                                    (- args.line2
                                                                       1)
                                                                    args.line2
                                                                    true)
                                        1))
                     {:start [args.line1 0] :end [args.line2 (end_line:len)]}))
            (local conform (require :conform))
            (conform.format {:async true :range range})))
