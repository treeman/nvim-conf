(require-macros :macros)

(local mason (require :mason))
(mason.setup)

(local mason-lspconfig (require :mason-lspconfig))
(mason-lspconfig.setup {:ensure_installed ["rust_analyzer"
                                           "ty"
                                           "expert"
                                           "clangd"
                                           "lua_ls"
                                           "cssls"
                                           "yamlls"
                                           "fennel_ls"
                                           "jsonls"]})

;; :automatic_enable {:exclude ["rust_analyzer" "jdtls"]}
;; :automatic_enable {:exclude ["rust_analyzer" "jdtls"]}})

(vim.diagnostic.config {:virtual_text false
                        :severity_sort true
                        :virtual_lines {:current_line true}})

(vim.lsp.inlay_hint.enable true)

;; I don't want objective-c and objective-cpp
(vim.lsp.config "clangd" {:filetypes {"c" "cpp"}})

(vim.lsp.enable "fennel_ls")

(augroup! :my-lsps
          (au! :LspAttach
               (λ [_]
                 (local snacks (require :snacks))
                 ;; (bmap! :n "<localleader>D" snacks.picker.lsp_declarations
                 ;;        {:silent true :desc "Declaration"})
                 ;; (bmap! :n "<localleader>d" snacks.picker.lsp_definitions
                 ;;        {:silent true :desc "Definition"})
                 (bmap! :n "<localleader>D" vim.lsp.buf.declaration
                        {:silent true :desc "Declaration"})
                 (bmap! :n "<localleader>d" vim.lsp.buf.definition
                        {:silent true :desc "Definition"})
                 (bmap! :n "<localleader>h" vim.lsp.buf.hover
                        {:silent true :desc "Hover"})
                 (bmap! :n "<localleader>s" vim.lsp.buf.signature_help
                        {:silent true :desc "Signature help"})
                 (bmap! :n "<localleader>r" snacks.picker.lsp_references
                        {:silent true :desc "References"})
                 (bmap! :n "<localleader>i" snacks.picker.lsp_implementations
                        {:silent true :desc "Implementation"})
                 (bmap! :n "<localleader>t" snacks.picker.lsp_type_definitions
                        {:silent true :desc "Type definition"})
                 (bmap! :n "<localleader>x" vim.lsp.buf.code_action
                        {:silent true :desc "Code action"})
                 (bmap! :n "<localleader>R" vim.lsp.buf.rename
                        {:silent true :desc "Rename"})
                 (bmap! :n "<localleader>l"
                        #(vim.diagnostic.open_float {:focusable false})
                        {:silent true :desc "Diagnostics"})
                 (bmap! :n "<localleader>I" snacks.picker.lsp_incoming_calls
                        {:silent true :desc "Incoming calls"})
                 (bmap! :n "<localleader>O" snacks.picker.lsp_outgoing_calls
                        {:silent true :desc "Outgoing calls"})
                 (bmap! :n "<localleader>S" snacks.picker.lsp_symbols
                        {:silent true :desc "LSP symbols"})
                 (bmap! :n "<localleader>w" snacks.picker.lsp_workspace_symbols
                        {:silent true :desc "LSP workspace symbols"}))))
