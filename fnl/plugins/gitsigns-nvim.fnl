{1 "https://github.com/lewis6991/gitsigns.nvim"
 :event [:BufReadPost :BufNewFile]
 :opts {:signs {:add {:text "+"}
                :change {:text "~"}
                :delete {:text "-"}
                :topdelete {:text "-"}
                :changedelete {:text "~"}}}}
