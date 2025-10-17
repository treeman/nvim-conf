(require-macros :macros)

(pack! "https://github.com/stevearc/conform.nvim")
; TODO doesn't call make automatically!
; (pack! "https://git.sr.ht/~technomancy/fnlfmt")

(local conform (require :conform))
(conform.setup {:formatters_by_ft {:fennel ["fnlfmt"]
                                   :lua ["stylua"]
                                   :javascript ["prettierd"]
                                   :typescript ["prettierd"]
                                   :css ["prettierd"]
                                   :scss ["prettierd"]
                                   :less ["prettierd"]
                                   :html ["prettierd"]
                                   :json ["prettierd"]
                                   :yaml ["prettierd"]
                                   ; :java [ "java_style" ]
                                   ; :toml [ "prettierd" ]
                                   :rust ["rustfmt"]
                                   :sql ["pg_format"]
                                   :mysql ["pg_format"]
                                   :plsql ["pg_format"]
                                   :elixir ["mix"]
                                   :heex ["mix"]}
                :formatters {:java_style {:command "astyle"
                                          :args ["--quiet"
                                                 "--style=google"
                                                 "--mode=java"]}
                             :fnlfmt {:command "fnlfmt"}}})

(command! :Format
          (fn [args]
            ;(print (vim.inspect args))
            (local range
                   (when (not= args.count -1)
                     (local end_line (. (vim.api.nvim_buf_get_lines 0
                                                                    (- args.line2
                                                                       1)
                                                                    args.line2
                                                                    true)
                                        1))
                     {:start [args.line1 0]
                      :end [args.line2 (: end_line :len)]}))
            (conform.format {:async true :range range})) {:range true})

(augroup! :formatting (au! :BufWritePre
                           (fn [args]
                             (conform.format {:bufnr args.buf
                                              :timeout_ms 2500
                                              :lsp_fallback "fallback"})
                             ; Need to return false to avoid destroying the autocmd
                             false)))
