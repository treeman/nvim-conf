{1 "https://github.com/andymass/vim-matchup"
 :event [:BufReadPost :BufNewFile]
 :before #(g! :matchup_matchparen_offscreen {:method "popup"})}
