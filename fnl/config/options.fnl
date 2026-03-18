(require-macros :laurel.macros)

;; Difficult to use fish as a default shell as plugins may depend on POSIX
;; Instead launch terminal with bash
(set! :shell "/bin/bash")

;; Use CLIPBOARD register + as default
;; Remember to install "xsel" for this to work!
;; For Neovim in WSL see:
;; https://github.com/neovim/neovim/wiki/FAQ#how-to-use-the-windows-clipboard-from-wsl
(set! :clipboard + ["unnamed" "unnamedplus"])

;; Backup files
(set! :backupdir (vim.fn.expand "~/.config/nvim/backup"))
;; where to put backup
(set! :backup true)
;; make backup files
(set! :swapfile false)
;; just annoying when I forcefully kill vim with the recovery
(set! :wildignore "*.swp,*.bak,*.pyc,*.class,*.o,*.obj,*.ali")

;; ignore files for file handling
(set! :hidden true)

;; can change buffers without saving
;; History and stuff
(set! :shada "!,'1000,<100,s100,h,f1")
(set! :shadafile (vim.fn.expand "~/.config/nvim/.shada"))

;; This causes a bug to insert stuff when opening file in ghostty!
;; Prevent <leader> from timing out
; (set! :timeout false)
; (set! :ttimeout false)

;; show invisible chars?
(set! :list false)
;; show tabs and trailing spaces
(set! :listchars "tab:>-,trail:-")
;; No fold on startup
(set! :foldenable false)
;; no real tabs please!
(set! :expandtab true)
;; when at 3 spaces, and I hit > ... go to 4, not 5
(set! :shiftround true)
;; auto indent amount when using indents ex >> and <<
(set! :shiftwidth 4)
;; when hitting tab or backspace, how wide should a tab be
(set! :softtabstop 4)
;; tabs width
(set! :tabstop 4)
;; keep indenting after newline
(set! :autoindent true)
(set! :smarttab true)

;; display relative line numbers
(set! :relativenumber true)
;; show line numbers
(set! :number true)
;; don't insert any extra pixel lines between rows
(set! :linespace 0)
;; tell us when anything is changed via :...
; (set! :report 0)

;; shortens messages to aviod 'press a key' prompt
(set! :shortmess "aOstTc")

;; always show current positions along the bottom
(set! :ruler true)
;; show the command being typed
(set! :showcmd true)
;; Use a gutter for git-gutter and LSP messages
(set! :signcolumn "yes")

;; Required settings for nvim-cmp
(set! :completeopt "menuone,noselect")

;; Hide "concealed" syntax, for example in Djot and markdown
(set! :conceallevel 2)

;; always show the status line
(set! :laststatus 2)

(set! :spell true)
(set! :spelllang ["en_us" "sv"])

;; speed up macros
(set! :lazyredraw true)

(set! :winborder "single")
(set! :termguicolors true)
(set! :background "dark")
