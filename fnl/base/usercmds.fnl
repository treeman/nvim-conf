(require-macros :laurel.macros)

(command! :UpdatePacks (fn []
  (vim.pack.update)
  ; Corresponds to `require("thyme"):setup()` in lua.
  (: (require :thyme) :setup)
  (vim.cmd "ThymeCacheClear")))
