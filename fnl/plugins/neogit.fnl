{1 "https://github.com/NeogitOrg/neogit"
 :cmd :Neogit
 :opts {:kind "floating"
        ;; split_above
        :graph_style "kitty"
        :auto_show_console false
        :mappings {:status {"=" "Toggle"}}
        :commit_editor {:kind "floating"}
        :commit_select_view {:kind "floating"}
        :commit_view {:kind "floating"}
        :log_view {:kind "floating"}
        :rebase_editor {:kind "floating"}
        :reflog_view {:kind "floating"}
        :merge_editor {:kind "floating"}
        :tag_editor {:kind "floating"}
        :description_editor {:kind "floating"}
        :preview_buffer {:kind "floating"}
        :popup {:kind "floating"}
        :stash {:kind "floating"}
        :refs_view {:kind "floating"}}
 :dependencies ["nvim-lua/plenary.nvim"
                "sindrets/diffview.nvim"
                "isakbm/gitgraph.nvim"
                "folke/snacks.nvim"]}
