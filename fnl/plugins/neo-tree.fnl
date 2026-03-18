{1 "https://github.com/nvim-neo-tree/neo-tree.nvim"
 :cmd :Neotree
 :branch "v3.x"
 :opts {:window {:mapping_options {:noremap true :nowait true}
                 :mappings {"l" "open"
                            "h" "close_node"
                            "!" "toggle_hidden"
                            "X" "delete"
                            ;;"/" "noop"
                            ;;"?" "noop"
                            "space" "none"
                            "<Esc>" "close_window"}}
        :filesystem {;; Use oil instead
                     :hijack_netrw_behavior "disabled"}}
 :dependencies ["nvim-lua/plenary.nvim"
                "nvim-tree/nvim-web-devicons"
                "rachartier/tiny-devicons-auto-colors.nvim"
                "MunifTanjim/nui.nvim"]}
