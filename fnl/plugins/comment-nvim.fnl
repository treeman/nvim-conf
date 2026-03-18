{1 "https://github.com/numToStr/Comment.nvim"
 :opts {:ignore "^$"}
 :event [:BufReadPost :BufNewFile]
 :init (λ []
           (local ft (require "Comment.ft"))
           ;; Force fennel to use double semicolons.
           (ft.set "fennel" ";; %s"))}
