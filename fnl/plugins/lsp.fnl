(require-macros :macros)

; Use mason to easily install LSP servers and other tools.
(pack! "https://github.com/mason-org/mason.nvim" :after
       (λ []
         (local pkg (require :mason))
         (pkg.setup)))

; Provides ready made configurations for many LSPs.
(pack! "https://github.com/neovim/nvim-lspconfig")

; Manages LSPs installed via Mason and enables them automatically.
; Note that we need to enable other LSPs manually with `vim.lsp.enable`.
(pack! "https://github.com/mason-org/mason-lspconfig.nvim" :after
       (λ []
         (local pkg (require :mason-lspconfig))
         (pkg.setup)))

(vim.diagnostic.config {:virtual_text false
                        :severity_sort true
                        :float {:scope "cursor"}})

(vim.lsp.inlay_hint.enable true)

; We don't want objective-c and objective-cpp
(vim.lsp.config "clangd" {:filetypes {"c" "cpp"}})

(vim.lsp.config "expert"
                {:cmd ["expert"]
                 :root_markers ["mix.exs" ".git"]
                 :filetypes ["elixir" "eelixir" "heex"]})

; TODO
; You can use nvim_get_runtime_files() to get all Lua files under lsp/ directory in all of your 'runtimepath', then trim the .lua extension, and feed them to vim.lsp.enable()
; Then we can skip mason-lspconfig and simply rely on :Mason to install LSPs
(vim.lsp.enable "expert")

; NOTE there are other cool possibilities listed in nvim-lspconfig
(augroup! :my-lsps
          (au! :LspAttach
               (λ [args]
                 (bmap! :n "<localleader>D" vim.lsp.buf.declaration
                        {:silent true :desc "Declaration"})
                 (bmap! :n "<localleader>d" vim.lsp.buf.definition
                        {:silent true :desc "Definition"})
                 (bmap! :n "<localleader>h" vim.lsp.buf.hover
                        {:silent true :desc "Hover"})
                 (bmap! :n "<localleader>s" vim.lsp.buf.signature_help
                        {:silent true :desc "Signature help"})
                 (bmap! :n "<localleader>r" vim.lsp.buf.references
                        {:silent true :desc "References"})
                 (bmap! :n "<localleader>i" vim.lsp.buf.implementation
                        {:silent true :desc "Implementation"})
                 (bmap! :n "<localleader>t" vim.lsp.buf.type_definition
                        {:silent true :desc "Type definition"})
                 (bmap! :n "<localleader>x" vim.lsp.buf.code_action
                        {:silent true :desc "Code action"})
                 (bmap! :n "<localleader>R" vim.lsp.buf.rename
                        {:silent true :desc "Rename"})
                 (bmap! :n "<localleader>l"
                        #(vim.diagnostic.open_float {:focusable false})
                        {:silent true :desc "Diagnostics"})
                 (bmap! :n "<localleader>I" vim.lsp.buf.incoming_calls
                        {:silent true :desc "Incoming calls"})
                 (bmap! :n "<localleader>O" vim.lsp.buf.outgoing_calls
                        {:silent true :desc "Outgoing calls"}))))
