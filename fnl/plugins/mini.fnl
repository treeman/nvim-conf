{:src "https://github.com/nvim-mini/mini.nvim"
 :version :main
 :lazy false
 :after (λ []
          (: (require :mini.git) :setup {})
          (: (require :mini.trailspace) :setup {})
          (: (require :mini.cursorword) :setup {})
          (: (require :mini.notify) :setup {})
          (: (require :mini.surround) :setup {}))}
