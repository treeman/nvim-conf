; Define leader key as early as possible as some plugins may not work if they're loaded before
; the leader is defined.
(require :base.leader)
(require :base.bugs)
(require :base.options)
(require :base.usercmds)
(require :base.autocmds)
(require :base.keymaps)

; Maybe we should just list all modules and require them automatically...?
; (require :plugins)
(require :plugins.snacks)
(require :plugins.colorscheme)
(require :plugins.formatting)
(require :plugins.treesitter)
(require :plugins.lsp)
