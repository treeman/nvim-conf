[;; File pickers
 {:src "https://github.com/nvim-telescope/telescope-fzf-native.nvim"
  :build ["make"]
  :dep_of "telescope.nvim"}
 {:src "https://github.com/nvim-telescope/telescope.nvim"
  :on_require :telescope
  :after (λ []
           (local telescope (require :telescope))
           (local actions (require :telescope.actions))
           (telescope.setup {:defaults {:file_ignore_patterns ["node_modules"]
                                        :mappings {:i {"<esc>" actions.close}}
                                        :pickers {:find_files {:hidden true}}
                                        :layout_config {:horizontal {:preview_width 0.5}
                                                        :width {:padding 5}}
                                        :path_display ["filename_first"]}})
           (telescope.load_extension "fzf"))}
 ;; Drawer
 {:src "https://github.com/A7Lavinraj/fyler.nvim"
  :on_require :fyler
  :setup {:icon_provider "nvim_web_devicons"
          :default_explorer true
          :close_on_select false
          :indentscope {:marker "┆"}
          :win {:kind "split_left_most"
                :kind_presets {:split_left_most {:width "40abs" :height "1rel"}}
                :win_opts {:spell false}}
          :git_status {:symbols {:Untracked "?"
                                 :Added "+"
                                 :Modified "~"
                                 :Deleted "-"
                                 :Renamed ">"
                                 :Copied "*"
                                 :Conflict "!"
                                 :Ignored "."}}}}
 ;; Paths
 "https://github.com/nanotee/zoxide.vim"
 {:src "https://github.com/ethanholz/nvim-lastplace"
  :lazy false
  :on_require :nvim-lastplace
  :setup {:lastplace_ignore_buftype ["quickfix" "nofile" "help" "terminal"]
          :lastplace_ignore_filetype ["dashboard"
                                      "gitcommit"
                                      "gitrebase"
                                      "hgcommit"
                                      "svn"
                                      "toggleterm"]
          :lastplace_open_folds true}}]
