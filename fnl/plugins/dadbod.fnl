(require-macros :macros)

{1 "tpope/vim-dadbod"
 :event ["BufReadPost" "BufNewFile"]
 :cmd ["DB" "DBUI" "DBCompletionClearCache" "DBUIAddConnection" "DBUIToggle"]
 :dependencies ["kristijanhusak/vim-dadbod-completion"
                "kristijanhusak/vim-dadbod-ui"]
 :init (λ []
         (g! :db_ui_use_nerd_fonts 1))}
