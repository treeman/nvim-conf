{1 "https://github.com/DrKJeff16/project.nvim"
 :lazy false
 :opts {;; Workaround for some LSPs using ~ as root
        :lsp {:ignore ["ts_ls" "cssls" "html"]}
        :silent_chdir true
        :log {:enabled false}
        :scope_chdir "win"
        :on_attach (λ [dir _method]
                     (vim.notify (.. "cwd " dir)))
        :patterns [".git"
                   "_darcs"
                   ".hg"
                   ".bzr"
                   ".svn"
                   "Makefile"
                   "package.json"
                   "rocks.toml"
                   "lazy-lock.json"
                   "nvim-pack-lock.json"]}}

;; :event ["BufReadPost" "BufNewFile"]}
