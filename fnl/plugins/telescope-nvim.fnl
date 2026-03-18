[{1 "https://github.com/nvim-telescope/telescope.nvim"
  :dependencies [{1 "https://github.com/nvim-telescope/telescope-fzf-native.nvim"
                  :build "make"}]
  :config (λ []
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
            (telescope.load_extension "fzf"))}]
