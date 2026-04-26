;; Override the djot parser to use the local development build at
;; ~/code/tree-sitter-djot. Queries are overridden via the symlink at
;; queries/djot -> ~/code/tree-sitter-djot/queries.
(vim.treesitter.language.add :djot
                             {:path (vim.fn.expand "~/code/tree-sitter-djot/djot.so")})
