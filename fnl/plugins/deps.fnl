[;; Generic dependency repositories
 {:src "https://github.com/nvim-lua/popup.nvim" :dep_of "telescope.nvim"}
 {:src "https://github.com/nvim-lua/plenary.nvim"
  :on_require :plenary
  :dep_of "neo-tree.nvim"}
 {:src "https://github.com/MunifTanjim/nui.nvim" :dep_of "neo-tree.nvim"}
 {:src "https://github.com/nvim-neotest/nvim-nio" :on_require :nio}
 ;; Icons
 "https://github.com/rachartier/tiny-devicons-auto-colors.nvim"
 {:src "https://github.com/nvim-tree/nvim-web-devicons"
  :dep_of ["fyler.nvim" "tiny-devicons-auto-colors.nvim" "neo-tree.nvim"]}]
