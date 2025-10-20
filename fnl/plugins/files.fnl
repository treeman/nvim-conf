[
 ;; File pickers
    ;; TODO lacks a build parameter
    { :src "https://github.com/nvim-telescope/telescope-fzf-native.nvim" :dep_of "telescope.nvim"}
    { :src "https://github.com/nvim-telescope/telescope.nvim" :on_require :telescope :after
       (λ []
          (local telescope (require :telescope))
          (local actions (require :telescope.actions))
          (telescope.setup {:defaults {:file_ignore_patterns ["node_modules"]
                                       :mappings {:i {"<esc>" actions.close}}
                                       :pickers {:find_files {:hidden true}
                                                 :layout_config {:horizontal {:preview_width 0.6}
                                                                             :width {:padding 5}}
                                                 :path_display ["filename_first"]}}})
          (telescope.load_extension "fzf"))}
    ;; Drawer
    { :src "https://github.com/A7Lavinraj/fyler.nvim" :on_require :fyler :after
       (λ []
         (local pkg (require :fyler))
         (pkg.setup {:icon_provider "nvim_web_devicons"
                     :default_explorer false}))}]

