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
  (when (not disable?)
    {:timeout_ms 2500}))

; :injected (require :formatters.injected)}})

{1 "https://github.com/stevearc/conform.nvim"
 :cmd ["ConformInfo"]
 :event "BufWritePre"
 :opts {:formatters_by_ft {:_ {1 "trim_whitespace" :lsp_format "prefer"}
                           :fennel ["fnlfmt"]
                           :lua ["stylua"]
                           :javascript ["prettierd"]
                           :typescript ["prettierd"]
                           :css ["prettierd"]
                           :scss ["prettierd"]
                           :less ["prettierd"]
                           :html ["prettierd"]
                           :json ["prettierd"]
                           :yaml ["prettierd"]
                           :java {:lsp_format "prefer"}
                           ; :java ["java_style"]
                           ; :toml [ "prettierd" ]
                           :rust ["rustfmt"]
                           :sql ["pg_format"]
                           :mysql ["pg_format"]
                           :plsql ["pg_format"]
                           :elixir ["mix"]
                           :python ["black"]
                           ; :djot ["injected"]
                           :heex ["mix"]}
        :format_on_save format_on_save
        :formatters {:java_style {:command "astyle"
                                  :args ["--quiet"
                                         "--style=google"
                                         "--mode=java"]}
                     :fnlfmt {:command "fnlfmt"}}}}
