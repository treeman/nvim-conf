(require-macros :macros)

[;; Formatting
 "https://github.com/stevearc/conform.nvim"
 ;; LSP and external tools
 ;; Use mason to easily install LSP servers and other tools.
 {:src "https://github.com/mason-org/mason.nvim" :dep_of :mason-lspconfig.nvim}
 ;; Provides ready made configurations for many LSPs.
 {:src "https://github.com/neovim/nvim-lspconfig"
  :dep_of :mason-lspconfig.nvim}
 ;; Manages LSPs installed via Mason and enables them automatically.
 ;; Note that we need to enable other LSPs manually with `vim.lsp.enable`.
 "https://github.com/mason-org/mason-lspconfig.nvim"
 ;; Treesitter
 {:src "https://github.com/nvim-treesitter/nvim-treesitter"
  :version :main
  :after_build #(vim.cmd "TSUpdate")}
 {:src "https://github.com/nvim-treesitter/nvim-treesitter-textobjects"
  :version :main
  :on_require :nvim-treesitter-textobjects
  :setup {:select {:lookahead true}}}
 ;; Git
 {:src "https://github.com/sindrets/diffview.nvim" :dep_of :neogit}
 {:src "https://github.com/isakbm/gitgraph.nvim" :dep_of :neogit}
 {:src "https://github.com/NeogitOrg/neogit"
  :on_require :neogit
  :cmd :Neogit
  :setup {:kind "split_above"
          :graph_style "kitty"
          :auto_show_console false
          :mappings {:status {"=" "Toggle"}}
          :commit_editor {:kind "auto"}}}
 {:src "https://github.com/FredeHoey/tardis.nvim"
  :on_require :tardis-nvim
  :setup {:keymap {"next" "<Left>"
                   "prev" "<Right>"
                   "quit" "q"
                   "commit" "<C-c>"}}
  :cmd "Tardis"}
 {:src "https://github.com/lewis6991/gitsigns.nvim"
  :on_require :gitsigns
  :event [:BufReadPost :BufNewFile]
  :setup {:signs {:add {:text "+"}
                  :change {:text "~"}
                  :delete {:text "-"}
                  :topdelete {:text "-"}
                  :changedelete {:text "~"}}}}
 {:src "https://github.com/FabijanZulj/blame.nvim"
  :cmd :BlameToggle
  :after (λ []
           (local blame (require :blame))
           (local formats (require :blame.formats.default_formats))
           (blame.setup {:date_format "%Y-%m-%d"
                         :merge_consecutive true
                         :format_fn formats.date_message
                         :mappings {:commit_info "i"
                                    :stack_push "<Left>"
                                    :stack_pop "<Right>"
                                    :show_commit "<CR>"
                                    :close ["<esc>" "q"]}
                         :colors ["#867462"
                                  "#D47766"
                                  "#EBC06D"
                                  "#85B695"
                                  "#A3A9CE"
                                  "#CF9BC2"
                                  "#BD8183"
                                  "#E49B5D"
                                  "#78997A"
                                  "#7F91B2"
                                  "#B380B0"]}))}
 ;; Comments
 {:src "https://github.com/numToStr/Comment.nvim"
  :on_require :Comment
  :setup {:ignore "^$"}
  :event [:BufReadPost :BufNewFile]}
 {:src "https://github.com/folke/todo-comments.nvim"
  :on_require :todo-comments
  :event [:BufReadPost :BufNewFile]
  ;; Don't require a colon.
  ;; Match without the extra colon.
  :setup {:highlight {:pattern ".*<(KEYWORDS)"}
          :search {:pattern "\b(KEYWORDS)\b"}}}
 ;; Navigation
 {:src "https://github.com/andymass/vim-matchup"
  :event [:BufReadPost :BufNewFile]
  :before #(g! :matchup_matchparen_offscreen {:method "popup"})}
 {:src "https://github.com/folke/trouble.nvim"
  :cmd :Trouble
  :on_require :trouble
  :setup {:modes {:cascade {:mode "diagnostics"
                            :filter (λ [items]
                                      (var severity
                                           vim.diagnostic.severity.HINT)
                                      (each [_ item (ipairs items)]
                                        (set severity
                                             (math.min severity item.severity)))
                                      (vim.tbl_filter (λ [item]
                                                        (= item.severity
                                                           severity))
                                                      items))}}}}
 ;; Language specific plugins]
 {:src "https://github.com/mfussenegger/nvim-jdtls"
  :ft "java"
  :on_require :jdtls}
 {:src "https://github.com/otherjoel/vim-pollen" :ft "pollen"}
 {:src "https://github.com/folke/lazydev.nvim"
  :ft :lua
  :on_require :lazydev
  :setup {}}]
