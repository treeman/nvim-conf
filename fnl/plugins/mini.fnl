{:src "https://github.com/nvim-mini/mini.nvim"
 :version :main
 :lazy false
 :after (λ []
          (local git (require :mini.git))
          (local trailspace (require :mini.trailspace))
          (local cursorword (require :mini.cursorword))
          (local surround (require :mini.surround))
          (local notify (require :mini.notify))
          (git.setup {})
          (trailspace.setup {})
          (cursorword.setup {})
          (surround.setup {})
          (notify.setup {:lsp_progress {:enable false :level "ERROR"}}))}
