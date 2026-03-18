{1 "https://github.com/nvim-mini/mini.nvim"
 :version "*"
 :lazy false
 :config (λ []
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
