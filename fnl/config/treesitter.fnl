(require-macros :macros)

(local nvim-treesitter (require :nvim-treesitter))

; Ignore auto install for these filetypes:
(local ignored_ft [])

(augroup! :treesitter
          (au! :FileType
               (λ [args]
                 (local bufnr args.buf)
                 (local ft args.match)
                 (when (not (vim.list_contains ignored_ft ft)) ; Auto install grammars unless explicitly ignored.
                   (: (nvim-treesitter.install ft) :await
                      (λ []
                        (local installed (nvim-treesitter.get_installed))
                        (when (and (vim.api.nvim_buf_is_loaded bufnr)
                                   (vim.list_contains installed ft))
                          ; Enable highlight only if there's an installed grammar.
                          (vim.treesitter.start bufnr))))))))
