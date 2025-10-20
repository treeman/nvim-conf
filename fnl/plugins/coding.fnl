[;; Formatting
 "https://github.com/stevearc/conform.nvim"
 ;; LSP and external tools
 ;; Use mason to easily install LSP servers and other tools.
 {:src "https://github.com/mason-org/mason.nvim" :dep_of :mason-lspconfig.nvim}
 ;; Provides ready made configurations for many LSPs.
 {:src "https://github.com/neovim/nvim-lspconfig"
  :dep_of :mason-lspconfig.nvim}
 ;; Manages LSPs installed via Mason and enables them automatically.
 ;; Note that we need to enable other LSPs manually with `vim.lsp.enable`.
 "https://github.com/mason-org/mason-lspconfig.nvim"
 ;; Treesitter
 {:src "https://github.com/nvim-treesitter/nvim-treesitter" :version :main}]
