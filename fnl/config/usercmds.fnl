(require-macros :laurel.macros)

(command! :ToggleSpell #(set! :spell (not (vim.opt.spell:get))))
(command! :Rename #(: (require :snacks.rename) :rename_file))
