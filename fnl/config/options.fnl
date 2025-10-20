(require-macros :laurel.macros)

; Difficult to use fish as a default shell as plugins may depend on POSIX
; Instead launch terminal with bash
(set! :shell "/bin/bash")

; Use CLIPBOARD register + as default
; Remember to install "xsel" for this to work!
; For Neovim in WSL see:
; https://github.com/neovim/neovim/wiki/FAQ#how-to-use-the-windows-clipboard-from-wsl
(set! :clipboard + ["unnamed" "unnamedplus"])

; Backup files
(set! :backupdir (vim.fn.expand "~/.config/nvim/backup")) ; where to put backup
(set! :backup true) ; make backup files
(set! :swapfile false) ; just annoying when I forcefully kill vim with the recovery
(set! :wildignore "*.swp,*.bak,*.pyc,*.class,*.o,*.obj,*.ali") ; ignore files for file handling
(set! :hidden true) ; can change buffers without saving
; History and stuff
(set! :shada "!,'1000,<100,s100,h,f1")
(set! :shadafile (vim.fn.expand "~/.config/nvim/.shada"))

; This causes a bug to insert stuff when opening file!
; Prevent <leader> from timing out
(set! :timeout false)
(set! :ttimeout false)

; Text display
(set! :list false) ; show invisible chars?
(set! :listchars "tab:>-,trail:-") ; show tabs and trailing spaces
(set! :foldenable false) ; disable folding at startup

; Text formatting
(set! :expandtab true) ; no real tabs please!
(set! :shiftround true) ; when at 3 spaces, and I hit > ... go to 4, not 5
(set! :shiftwidth 4) ; auto indent amount when using indents ex >> and <<
(set! :softtabstop 4) ; when hitting tab or backspace, how wide should a tab be
(set! :tabstop 4) ; tabs width
(set! :autoindent true) ; keep indenting after newline
(set! :smarttab true) ; insert tabs on the start according to shiftwidth, not tabstop

; UI
(set! :relativenumber true) ; display relative line numbers
(set! :number true) ; show line numbers
(set! :linespace 0) ; don't insert any extra pixel lines between rows
(set! :report 0) ; tell us when anything is changed via :...
(set! :shortmess "aOstTc") ; shortens messages to aviod 'press a key' prompt
(set! :ruler true) ; always show current positions along the bottom
(set! :showcmd true) ; show the command being typed
(set! :signcolumn "yes") ; Use a gutter for git-gutter and LSP messages
(set! :completeopt "menuone,noselect") ; Required settings for nvim-cmp
(set! :conceallevel 2) ; Hide "concealed" syntax, for example in Djot and markdown
(set! :laststatus 2) ; always show the status line

(set! :spell true)
(set! :spelllang [ "en_us" "sv" ])

(set! :lazyredraw true) ; speed up macros

(set! :termguicolors true)
(set! :background "dark")
