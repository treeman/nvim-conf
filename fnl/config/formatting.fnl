(require-macros :macros)

(λ format_on_save [bufnr]
  (local ignored_ft ["python"])
  (local ft (. vim :bo bufnr :filetype))
  (local bufname (vim.api.nvim_buf_get_name bufnr))
  (local disable?
         (or (vim.list_contains ignored_ft ft) (?. vim.g :disable_autoformat)
             (?. vim.b bufnr :disable_autoformat)
             (bufname:match "/euronetics/schedule/")
             (bufname:match "/euronetics/vbanken/")
             (bufname:match "/code/jonashietala/templates")))
  (local lsp? (not (vim.list_contains [:elixir :heex] ft)))
  (when (not disable?)
    {:timeout_ms 2500 :lsp_fallback lsp?}))

(local conform (require :conform))

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
            (conform.format {:async true :range range})) {:range true})

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
                :format_on_save format_on_save
                :formatters {:java_style {:command "astyle"
                                          :args ["--quiet"
                                                 "--style=google"
                                                 "--mode=java"]}
                             :fnlfmt {:command "fnlfmt"}}})
