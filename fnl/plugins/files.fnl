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
           ;; Not sure how to use snacks.picker for this...?
           (telescope.load_extension "projects")
           (telescope.load_extension "fzf"))}
 ; {:src "https://github.com/dmtrKovalenko/fff.nvim"
 ;  ;; It's just slower than the snacks picker
 ;  :enabled false
 ;  :on_require :fff
 ;  :build ["cargo" "build" "--release"]}
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
          :lastplace_open_folds true}}
 ;; Projects and rooting
 {:src "https://github.com/DrKJeff16/project.nvim"
  :on_require :project
  :lazy false
  :setup {;; Workaround for some LSPs using ~ as root
          :ignore_lsp ["ts_ls" "cssls" "html"]
          :silent_chdir true
          :log {:enabled false}
          :scope_chdir "win"
          :on_attach (λ [dir _method]
                       (vim.notify (.. "cwd " dir)))
          :patterns [".git"
                     "_darcs"
                     ".hg"
                     ".bzr"
                     ".svn"
                     "Makefile"
                     "package.json"
                     "rocks.toml"
                     "lazy-lock.json"
                     "nvim-pack-lock.json"]}
  :event ["BufReadPost" "BufNewFile"]}]
