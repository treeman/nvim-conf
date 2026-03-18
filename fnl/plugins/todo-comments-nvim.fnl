{1 "https://github.com/folke/todo-comments.nvim"
 :enabled false
 :event [:BufReadPost :BufNewFile]
 ;; Don't require a colon.
 ;; Match without the extra colon.
 :opts {:highlight {:pattern ".*<(KEYWORDS)"}
        :search {:pattern "\b(KEYWORDS)\b"}}}
