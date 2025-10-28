(require-macros :macros)
(local util (require :util))
(local cybershard (util.cybershard_keyboard?))

; Use ( as [ everywhere for custom layouts that has ()
; on the base layer, but [] are hidden.
(when cybershard
  (do
    (map! "n" [:remap] "(" "[")
    (map! "n" [:remap] ")" "]")
    (map! "o" [:remap] "(" "[")
    (map! "o" [:remap] ")" "]")
    (map! "x" [:remap] "(" "[")
    (map! "x" [:remap] ")" "]")))

; Happy windows switching
(if cybershard
    (do
      (map! :nt "<C-left>" "<c-w>h")
      (map! :nt "<C-left>" "<c-w>h")
      (map! :nt "<C-down>" "<c-w>j")
      (map! :nt "<C-up>" "<c-w>k")
      (map! :nt "<C-right>" "<c-w>l"))
    (do
      (map! :nt "<C-h>" "<c-w>h")
      (map! :nt "<C-j>" "<c-w>j")
      (map! :nt "<C-k>" "<c-w>k")
      (map! :nt "<C-l>" "<c-w>l")))

; Edit file with pre-filled path from the current file
(map! :n "<leader>ef" ":e <C-R>=expand('%:p:h') . '/'<CR>"
      {:desc "Edit relative file"})

; Goto previous buffer
(map! :n "<leader>B" ":e #<CR>" {:desc "Previous buffer"})

(map! :i "<C-l>" "λ")

;; Copy/paste to mouse clipboard quickly
(map! "n" "<leader>p" "\"*p" {:silent true :desc "Paste from mouse"})
(map! "n" "<leader>P" "\"*P" {:silent true :desc "Paste before from mouse"})
(map! "n" "<leader>y" "\"*y" {:silent true :desc "Yank into mouse"})
(map! "n" "<leader>Y" "\"*Y" {:silent true :desc "Yank line into mouse"})
;; Don't overwrite register when pasting in visual selection
(map! "x" "p" "\"_dP")

(map! "n" "]q" ":cnext<cr>" {:desc "Next quickfix"})
(map! "n" "[q" ":cprevious<cr>" {:desc "Prev quickfix"})
(map! "n" "]Q" ":clast<cr>" {:desc "Last quickfix"})
(map! "n" "[Q" ":cfirst<cr>" {:desc "First quickfix"})

(map! "n" "]l" ":lnext<cr>" {:desc "Next loclist"})
(map! "n" "[l" ":lprevious<cr>" {:desc "Prev loclist"})
(map! "n" "]L" ":llast<cr>" {:desc "Last loclist"})
(map! "n" "[L" ":lfirst<cr>" {:desc "First loclist"})

;; Don't get caught in terminal)
(map! "t" "<Esc>" "<C-\\><C-n>")

;; Move visual lines
(map! "n" "<up>" "gk")
(map! "n" "<down>" "gj")

;; Don't move cursor when joining lines
(map! "n" "J" "mzJ`z")

;; Drawer
(map! :n "<leader>d" (λ []
                       (local fyler (require :fyler))
                       (fyler.toggle)) {:desc "Drawer"})

; Edit files in current directory
(map! :n "<leader>e."
      (λ []
        (local fyler (require :fyler))
        (fyler.open {:dir (vim.fn.expand "%:p:h")}))
      {:desc "Edit directory of buffer"})

(local snacks (require :snacks))
(map! :n :<leader>b #(snacks.picker.buffers))
(map! :n :<leader>o #(snacks.picker.recent) {:silent true :desc "Old files"})
(map! :n :<leader>er #(snacks.picker.resume) {:silent true :desc "Resume pick"})
(map! :n "<leader>f" #(snacks.picker.files) {:silent true :desc "Find files"})
(map! :n "<leader>F" #(snacks.picker.files {:cwd (vim.fn.expand "%:p:h")})
      {:silent true :desc "Find files from current file"})

(map! :n "<leader>ec" #(snacks.picker.files {:cwd (vim.fn.stdpath "config")})
      {:silent true :desc "Find config file"})

(map! :n "gb" #(snacks.picker.git_branches) {:silent true :desc "Git branches"})
(map! :n "gl" #(snacks.picker.git_log) {:silent true :desc "Git log"})
(map! :n "gp" #(snacks.picker.projects) {:silent true :desc "Projcts"})

(map! :n "<leader>/" #(snacks.picker.grep) {:silent true :desc "Grep"})
(map! :n "z=" #(snacks.picker.spelling) {:silent true :desc "Spell suggest"})
(map! :n "<leader>hh" #(snacks.picker.help) {:silent true :desc "Help"})
(map! :n "<leader>hi" #(snacks.picker.highlights)
      {:silent true :desc "Highlights"})

;; Telescoping into a personal knowledge base is really pleasant,
(λ find_org_file [base_folder]
  (local folder (.. (vim.fn.expand "~/org/") base_folder "/"))
  ;; Archive can be gross, hide it by default.
  (local excluded (if (not= base_folder "archive")
                      ["archive/*"]
                      []))
  (snacks.picker.files {:cwd folder :exclude excluded}))

(map! "n" "<leader><leader>" #(find_org_file "") {:desc "Org files"})
(map! "n" "<leader>ep" #(find_org_file "projects") {:desc "Org projects"})
(map! "n" "<leader>en" #(find_org_file "notes") {:desc "Org notes"})
(map! "n" "<leader>eA" #(find_org_file "archive") {:desc "Org archive"})

(map! :n "gw" #(: (require :blog.telescope) :find_markup)
      {:desc "Find blog content"})

(λ dial [dir sel]
  (local dial (require :dial.map))
  (dial.manipulate dir sel))

(map! "n" "<C-a>" #(dial "increment" "normal"))
(map! "n" "<C-x>" #(dial "decrement" "normal"))
(map! "n" "g<C-a>" #(dial "increment" "gnormal"))
(map! "n" "g<C-x>" #(dial "decrement" "gnormal"))
(map! "x" "<C-a>" #(dial "increment" "visual"))
(map! "x" "<C-x>" #(dial "decrement" "visual"))
(map! "x" "g<C-a>" #(dial "increment" "gvisual"))
(map! "x" "g<C-x>" #(dial "decrement" "gvisual"))

;; Maximize current buffer
(g! :maximizer_set_default_mapping false)
(map! :n "<C-w>m" (<Cmd> "MaximizerToggle")
      {:silent true :desc "Maximize window"})

;; Git
(map! :n "gs" (<Cmd> :Neogit) {:desc "Git status"})
; (map! :n "<leader>g" (<Cmd> :Neogit) {:desc "Git status"})
(map! :n "gt" (<Cmd> :Tardis) {:desc "Git timemachine (Tardis)"})
(map! :n "g<space>" ":Git " {:desc "Git"})
(map! :n "gB" (<Cmd> "BlameToggle virtual") {:silent true :desc "Git blame"})

;; Sometimes the : shortcut work but other times it doesn't...
(map! :n "]h" #(: (require :gitsigns) :next_hunk) {:desc "Next hunk"})
(map! :n "[h" #(: (require :gitsigns) :prev_hunk) {:desc "Prev hunk"})

(map! :n "<leader>hs" (λ [] (local signs (require :gitsigns))
                        (signs.stage_hunk))
      {:desc "Stage hunk"})

(map! :n "<leader>hr" (λ [] (local signs (require :gitsigns))
                        (signs.reset_hunk))
      {:desc "Reset hunk"})

(map! :v "<leader>hs"
      (λ []
        (local signs (require :gitsigns))
        (signs.stage_hunk [(vim.fn.line ".") (vim.fn.line "v")]))
      {:desc "Stage hunk"})

(map! :v "<leader>hr"
      (λ []
        (local signs (require :gitsigns))
        (signs.reset_hunk [(vim.fn.line ".") (vim.fn.line "v")]))
      {:desc "Reset hunk"})

(map! :n "<leader>u" #(: (require :undotree) :open {:command "topleft 30vnew"})
      {:desc "Undotree"})

(map! :n "<leader>t" #(do
                        (local trouble (require :trouble))
                        (trouble.toggle "diagnostics"))
      {:desc "Trouble"})

(map! :n "<leader>q" #(do
                        (local trouble (require :trouble))
                        (trouble.toggle "quickfix"))
      {:desc "Trouble"})

(map! :n "<leader>w" #(do
                        (local trouble (require :trouble))
                        (trouble.toggle "symbols"))
      {:desc "Trouble"})

(map! :n "]t" #(do
                 (local trouble (require :trouble))
                 (trouble.next {:skip_groups true :jump true}))
      {:silent true :desc "Trouble next"})

(map! :n "[t" #(do
                 (local trouble (require :trouble))
                 (trouble.prev {:skip_groups true :jump true}))
      {:silent true :desc "Trouble prev"})

(map! :n "]T" #(do
                 (local trouble (require :trouble))
                 (trouble.last {:skip_groups true :jump true}))
      {:silent true :desc "Trouble last"})

(map! :n "[T" #(do
                 (local trouble (require :trouble))
                 (trouble.first {:skip_groups true :jump true}))
      {:silent true :desc "Trouble first"})

(map! :nxo "]f"
      #(: (require :nvim-treesitter-textobjects.move) :goto_next_start
          "@function.outer" "textobjects"))

;; Maps [f, ]f, [F, ]F for the different pairs.
(local ts_move_keys [{:key "f" :query "@function.outer" :desc "goto function"}
                     {:key "a"
                      :query "@attribute.inner"
                      :desc "goto attribute"}
                     {:key "b" :query "@block.inner" :desc "goto block"}
                     {:key "c" :query "@class.outer" :desc "goto class"}
                     {:key "x" :query "@comment.outer" :desc "goto comment"}
                     {:key "g"
                      :query ["@class.outer" "@function.outer"]
                      :desc "goto major"}])

(local ts_move (require :nvim-treesitter-textobjects.move))
(each [_ v (ipairs ts_move_keys)]
  (map! :nxo (.. "]" v.key) #(ts_move.goto_next_start v.query) {:desc v.desc})
  (map! :nxo (.. "[" v.key) #(ts_move.goto_previous_start v.query)
        {:desc v.desc})
  (map! :nxo (.. "]" (string.upper v.key)) #(ts_move.goto_next_end v.query)
        {:desc v.desc})
  (map! :nxo (.. "[" (string.upper v.key)) #(ts_move.goto_previous_end v.query)
        {:desc v.desc}))

; -- Some symbolic keymaps that don't have a string.upper()
; (map! :nxo "]=" #(ts_move.goto_next_start "@statement.outer")
;       {:desc "goto next statement"})

; (map! :nxo "[=" #(ts_move.goto_previous_start "@statement.outer")
;       {:desc "goto previous statement"})

; (map! :nxo "]," #(ts_move.goto_next_start "@parameter.outer")
;       {:desc "goto next parameter"})

; (map! :nxo "[," #(ts_move.goto_previous_start "@parameter.outer")
;       {:desc "goto previous parameter"})

(local ts_repeat_move (require "nvim-treesitter-textobjects.repeatable_move"))
;; Make the keys repeatable
(map! :nxo ";" ts_repeat_move.repeat_last_move)
(map! :nxo "," ts_repeat_move.repeat_last_move_opposite)
;; make builtin f, F, t, T also repeatable with) ; and ,
(map! :nxo "f" ts_repeat_move.builtin_f_expr {:expr true})
(map! :nxo "F" ts_repeat_move.builtin_F_expr {:expr true})
(map! :nxo "t" ts_repeat_move.builtin_t_expr {:expr true})
(map! :nxo "T" ts_repeat_move.builtin_T_expr {:expr true})

(local ts_swap (require :nvim-treesitter-textobjects.swap))
(map! :nxo "]," #(ts_swap.swap_next "@parameter.inner")
      {:desc "Swap next parameter"})

(map! :nxo "[," #(ts_swap.swap_previous "@parameter.inner")
      {:desc "Swap prev parameter"})

(local ts_select_keys [{:key "af"
                        :query "@function.outer"
                        :desc "Select around function"}
                       {:key "if"
                        :query "@function.inner"
                        :desc "Select inside function"}
                       {:key "ac"
                        :query "@class.outer"
                        :desc "Select around class"}
                       {:key "ic"
                        :query "@class.inner"
                        :desc "Select inside class"}
                       {:key "ab"
                        :query "@block.outer"
                        :desc "Select around block"}
                       {:key "ib"
                        :query "@block.inner"
                        :desc "Select inside block"}
                       {:key "aa"
                        :query "@attribute.outer"
                        :desc "Select around attribute"}
                       {:key "ia"
                        :query "@attribute.inner"
                        :desc "Seect inside attribute"}
                       {:key "ax"
                        :query "@comment.outer"
                        :desc "Select around comment"}
                       {:key "ix"
                        :query "@comment.inner"
                        :desc "Select inside comment"}
                       {:key "a="
                        :query "@statement.outer"
                        :desc "Select around statement"}
                       {:key "i="
                        :query "@statement.inner"
                        :desc "Select inside statement"}
                       {:key "a,"
                        :query "@parameter.outer"
                        :desc "Select around parameter"}
                       {:key "i,"
                        :query "@parameter.inner"
                        :desc "Select inside parameter"}])

(local ts_select (require :nvim-treesitter-textobjects.select))
(each [_ v (ipairs ts_select_keys)]
  (map! :xo v.key #(ts_select.select_textobject v.query "textobjects")
        {:desc v.desc}))

; -- Spell
; map("n", "ss", function()
;   vim.opt.spell = not (vim.opt.spell:get())
; end, { silent = true, desc = "Toggle spell" })
;
; -- Conceal
; map("n", "<leader>c", function()
;   local current_level = vim.wo.conceallevel
;   if current_level == 0 then
;     vim.wo.conceallevel = 2
;   else
;     vim.wo.conceallevel = 0
;   end
; end, { silent = true, desc = "Toggle conceal" })
;
;
; map("n", "<leader>rq", function()
;   require("replacer").run()
; end, {
;   silent = true,
;   desc = "Make quickfix editable for replacing in",
; })

; -- Replace word under cursor
; map("n", "<leader>rw", "<cmd>SearchReplaceSingleBufferCWord<cr>", {
;   desc = "Replace CWord",
; })
; -- Replace WORD under cursor
; map("n", "<leader>rW", "<cmd>SearchReplaceSingleBufferCWORD<cr>", {
;   desc = "Replace CWORD",
; })
; -- Replace "expression" (includes dots, not sure how useful this is)
; map("n", "<leader>re", "<cmd>SearchReplaceSingleBufferCExpr<cr>", {
;   desc = "Replace CExpr",
; })
; -- Replace visual selection
; map("v", "<C-r>", "<CMD>SearchReplaceSingleBufferVisualSelection<CR>", {
;   desc = "Replace selection",
; })
;
;
; local old_gx = vim.fn.maparg("gx", "n", nil, true)
; map("n", "gx", require("custom.open").gx_extended(old_gx.callback), { desc = old_gx.desc })

; M.buf_blog = function(buffer)
;   map("n", "<localleader>d", function()
;       require("blog.interaction").goto_def()
;       end, { buffer = buffer, desc = "Goto definition"})
;   map("n", "<localleader>h", require("blog.interaction").hover, { buffer = buffer, desc = "Hover help"})
; end
