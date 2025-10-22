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
                      :redo {:enabled true}}}}
 ;; Show marks
 {:src "https://github.com/chentoast/marks.nvim"
  :on_require :marks
  :setup {:default_mappings false
          :mappings {:set "m"
                     :delete "dm"
                     :delete_line "dm-"
                     :delete_buf "dm<space>"
                     :next "]m"
                     :prev "[m"
                     :preview "m:"}}
  :event [:BufReadPost :BufNewFile]}]
