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
(map! :n "<leader>d"
      (λ []
        (local fyler (require :fyler))
        (fyler.toggle {:kind :split_left_most})) {:desc "Drawer"})

(map! "n" "<leader>/" #(: (require :telescope.builtin) :live_grep)
      {:silent true :desc "Find in files"})

(map! "n" "<leader>f" #(: (require :telescope.builtin) :find_files)
      {:silent true :desc "Find files"})

(map! "n" "<leader>F" #(: (require :telescope.builtin) :find_files {:cwd (vim.fn.expand "%:p:h")})
      {:silent true :desc "Find files"})

(map! "n" "<leader>ec"
      #(: (require :telescope.builtin) :find_files {:cwd (vim.fn.stdpath "config")})
      {:silent true :desc "Find files"})

(map! "n" "<leader>b" #(: (require :telescope.builtin) :buffers) {:silent true :desc "Buffers"})
(map! "n" "<leader>o" #(: (require :telescope.builtin) :oldfiles) {:silent true :desc "Old files"})
(map! "n" "gb" #(: (require :telescope.builtin) :git_branches) {:silent true :desc "Git branches"})
(map! "n" "z=" #(: (require :telescope.builtin) :spell_suggest) {:silent true :desc "Spell suggest"})
(map! "n" "<leader>hh" #(: (require :telescope.builtin) :help_tags) {:silent true :desc "Help tags"})

;; Telescoping into a personal knowledge base is really pleasant,
(λ find_org_file [base_folder]
  (local Path (require :plenary.path))
  (local folder (.. (vim.fn.expand "~/org/") base_folder "/"))
  ;; Archive can be gross, need to explicitly ask for it, otherwise we'll hide it.
  (local ignore_files (if (not= base_folder "archive")
                          ["^archive/"]
                          []))

  (λ attach [prompt_bufnr map]
    (map! :i :<C-e> (λ []
                      (local current_picker
                             (action_state.get_current_picker prompt_bufnr))
                      (local input
                             (.. folder (current_picker:_get_prompt) ".dj"))
                      (local file (Path:new input))
                      (when (not (file:exists))
                        (file:touch {:parents true})
                        (actions.close prompt_bufnr)
                        (vim.cmd (.. "e " file " | w")))))
    true)

  (local builtin (require :telescope.builtin))
  (builtin.find_files {:file_ignore_patterns ignore_files
                       :attach_mappings attach
                       :cwd folder}))

(map! "n" "<leader><leader>" #(find_org_file "") {:desc "Org files"})
(map! "n" "<leader>ep" #(find_org_file "projects") {:desc "Org projects"})
(map! "n" "<leader>en" #(find_org_file "notes") {:desc "Org notes"})
(map! "n" "<leader>eA" #(find_org_file "archive") {:desc "Org archive"})

; map("n", "gw", function()
;   require("blog.telescope").find_markup()
; end, { desc = "Find blog content" })
;

;; Maximize current buffer
; map("n", "<C-w>m", ":MaximizerToggle<CR>", { silent = true, desc = "Maximize window" })
;
; -- Edit files in workspace
; map("n", "<leader>ed", ":Oil .<CR>", { desc = "Edit workspace" })
; -- Edit files in within the current directory
; map(
;   "n",
;   "<leader>e.",
;   ":Oil <C-R>=expand('%:p:h')<CR><CR>",
;   { desc = "Edit directory of buffer" }
; )
;
; map("n", "<leader>d", ":Neotree toggle=true<CR>", { desc = "Neotree" })
; map("n", "<leader>t", ":Trouble cascade toggle<cr>", { desc = "Diagnostics" })
;
; -- Git
; -- map("n", "gs", ":Neogit<CR>", { desc = "Git status" })
; map("n", "<leader>g", ":Neogit<CR>", { desc = "Git status" })
; map("n", "gt", ":Tardis git<CR>", { desc = "Git timemachine (Tardis)" })
; map("n", "g<space>", ":Git ", { desc = "Git" })

; map("n", "gB", ":BlameToggle<CR>", { silent = true, desc = "Git blame" })
; -- Jujutsu
; -- map("n", "<leader>j", ":JJ ", { desc = "Jujutsu" })
; -- map("n", "gl", function()
; --   require("jj.views.log").open()
; -- end, { desc = "Jujutsu log" })
; -- map("n", "gs", function()
; --   require("jj").execute("status")
; -- end, { desc = "Jujutsu status" })
; -- map("n", "gd", function()
; --   require("jj").execute("diff")
; -- end, { desc = "Jujutsu diff" })
; -- map("n", "gL", function()
; --   require("jj").execute("op log")
; -- end, { desc = "Jujutsu op log" })

;
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
; map("n", "<leader>sw", function()
;   require("spectre").open_visual({ select_word = true })
; end, {
;   silent = true,
;   desc = "Search current word",
; })
; map("v", "<leader>sw", function()
;   require("spectre").open_visual()
; end, {
;   silent = true,
;   desc = "Search selection",
; })
;
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
; map("n", "<C-a>", function()
;   require("dial.map").manipulate("increment", "normal")
; end, {
;   desc = "Increment number",
; })
; map("n", "<C-x>", function()
;   require("dial.map").manipulate("decrement", "normal")
; end, {
;   desc = "Decrement number",
; })
; map("v", "<C-a>", function()
;   require("dial.map").manipulate("increment", "visual")
; end, {
;   desc = "Increment number",
; })
; map("v", "<C-x>", function()
;   require("dial.map").manipulate("decrement", "visual")
; end, {
;   desc = "Decrement number",
; })
;
; map("n", "]t", function()
;   require("trouble").next({ skip_groups = true, jump = true })
; end, {
;   desc = "Next trouble",
;   silent = true,
; })
; map("n", "[t", function()
;   require("trouble").prev({ skip_groups = true, jump = true })
; end, {
;   desc = "Prev trouble",
;   silent = true,
; })
; map("n", "]T", function()
;   require("trouble").last({ skip_groups = true, jump = true })
; end, {
;   desc = "Last trouble",
;   silent = true,
; })
; map("n", "[T", function()
;   require("trouble").first({ skip_groups = true, jump = true })
; end, {
;   desc = "First trouble",
;   silent = true,
; })
;
; map("n", "<leader>u", function()
;   require("undotree").toggle()
; end, {
;   desc = "Undotree",
; })
;
; local old_gx = vim.fn.maparg("gx", "n", nil, true)
; map("n", "gx", require("custom.open").gx_extended(old_gx.callback), { desc = old_gx.desc })
