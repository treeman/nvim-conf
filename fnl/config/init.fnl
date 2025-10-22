; Define leader key as early as possible as some plugins may not work if they're loaded before
; the leader is defined.
(require :config.leader)

;; Then load all plugins so the rest of the configuration can reference them if needed to.
(require :plugins)

;; Finally load the rest of the configuration.
(require :config.bugs)
(require :config.options)
(require :config.usercmds)
(require :config.autocmds)
(require :config.keymaps)
(require :config.colorscheme)
(require :config.statusline)
(require :config.formatting)
(require :config.treesitter)
(require :config.lsp)
(require :config.undotree)
