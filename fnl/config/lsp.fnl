(require-macros :macros)

(local mason (require :mason))
(mason.setup)

(local mason-lspconfig (require :mason-lspconfig))
(mason-lspconfig.setup {:automatic_enable true})

(vim.diagnostic.config {:virtual_text false
                        :severity_sort true
                        :float {:scope "cursor"}})

(vim.lsp.inlay_hint.enable true)

;; I don't want objective-c and objective-cpp
(vim.lsp.config "clangd" {:filetypes {"c" "cpp"}})

;; These doesn't work!
; (map! "n" "]d"
;       #(do
;          (vim.diagnostic.jump {:count 1})
;          (vim.diagnostic.open_float {:focusable false}))
;       {:silent true :desc "Next diagnostic"})

; (map! "n" "[d"
;       #(do
;          (vim.diagnostic.jump {:count -1})
;          (vim.diagnostic.open_float {:focusable false}))
;       {:silent true :desc "Prev diagnostic"})

;; These are default bindings in Neovim but they don't open the diagnostic floats immediately.
;; These deprecated ones does work...
(map! "n" "]d" vim.diagnostic.goto_next {:silent true :desc "Next diagnostic"})
(map! "n" "[d" vim.diagnostic.goto_prev {:silent true :desc "Prev diagnostic"})

; NOTE there are other cool possibilities listed in nvim-lspconfig
(augroup! :my-lsps
          (au! :LspAttach
               (λ [_]
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
