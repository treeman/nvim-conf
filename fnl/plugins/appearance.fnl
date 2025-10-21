[{:src "https://github.com/savq/melange-nvim" :colorscheme "melange"}
 "https://github.com/nvim-lualine/lualine.nvim"
 ;; Animates yank and other things.
 {:src "https://github.com/rachartier/tiny-glimmer.nvim"
  :priority 10
  :on_require :tiny-glimmer
  :lazy false
  :setup {:overwrite {:yank {:enabled true}
                      :search {:enabled true}
                      :paste {:enabled true}
                      :undo {:enabled true}
                      :redo {:enabled true}}}}]
