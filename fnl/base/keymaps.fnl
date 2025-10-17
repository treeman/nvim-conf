(require-macros :macros)

; TODO local custom_keyboard = require("util.keyboard").has_custom_keyboard_layout()
(local custom_keyboard true)

; Happy windows switching
(if custom_keyboard
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

;
; -- Copy/paste to mouse clipboard quickly
; map("n", "<leader>p", '"*p', { silent = true, desc = "Paste from mouse"}))
; map("n", "<leader>P", '"*P', { silent = true, desc = "Paste before from mouse" })
; map("n", "<leader>y", '"*y', { silent = true, desc = "Yank into mouse" })
; map("n", "<leader>Y", '"*Y', { silent = true, desc = "Yank line into mouse" })
; -- Don't overwrite register when pasting in visual selection
; map("x", "p", '"_dP')
;
; -- if custom_keyboard then
; --   -- Should use arrow keys on home-row instead of jk,
; --   -- but it's fine to use jk when jumping to relative lines
; --   -- because they're on the number layer.
; --   local function block_jk(key)
; --     return function()
; --       if vim.v.count == 0 then
; --         vim.notify("stop mashing " .. key .. " you animal", vim.log.levels.ERROR)
; --       else
; --         vim.api.nvim_feedkeys(vim.v.count .. key, "n", true)
; --       end
; --     end
; --   end
; --
; --   map("n", "j", block_jk("j"))
; --   map("n", "k", block_jk("k"))
; --   map("v", "j", block_jk("j"))
; --   map("v", "k", block_jk("k"))
; -- end
;
; -- Use ( as [ everywhere for custom layouts that has ()
; -- on the base layer, but [] are hidden.
; if custom_keyboard then
;   map("n", "(", "[", { remap = true })
;   map("n", ")", "]", { remap = true })
;   map("o", "(", "[", { remap = true })
;   map("o", ")", "]", { remap = true })
;   map("x", "(", "[", { remap = true })
;   map("x", ")", "]", { remap = true })
; end
;
; map("n", "]q", ":cnext<cr>", { desc = "Next quickfix" })
; map("n", "[q", ":cprevious<cr>", { desc = "Prev quickfix" })
; map("n", "]Q", ":clast<cr>", { desc = "Last quickfix" })
; map("n", "[Q", ":cfirst<cr>", { desc = "First quickfix" })
;
; map("n", "]l", ":lnext<cr>", { desc = "Next loclist" })
; map("n", "[l", ":lprevious<cr>", { desc = "Prev loclist" })
; map("n", "]L", ":llast<cr>", { desc = "Last loclist" })
; map("n", "[L", ":lfirst<cr>", { desc = "First loclist" })
;
; -- Don't get caught in terminal
; map("t", "<Esc>", "<C-\\><C-n>")
;
; -- Move visual lines
; map("n", "<up>", "gk")
; map("n", "<down>", "gj")
;
; -- Don't move cursor when joining lines
; map("n", "J", "mzJ`z")
;
; -- Maximize current buffer
; map("n", "<C-w>m", ":MaximizerToggle<CR>", { silent = true, desc = "Maximize window" })
;
; -- Edit file with pre-filled path from the current file
; map("n", "<leader>ef", ":e <C-R>=expand('%:p:h') . '/'<CR>", { desc = "Edit relative file" })
;
; -- Goto previous buffer
; map("n", "<leader>B", ":edit #<CR>", { desc = "Previous buffer" })
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
; map("n", "<leader>es", ":e ~/org/scratch.dj<CR>", { desc = "Scratch" })
; map("n", "<leader>ej", ":e ~/org/journal.dj<CR>", { desc = "Journal" })
; map("n", "<leader>eg", ":e ~/org/goals.dj<CR>", { desc = "Goals" })
; map("n", "<leader>eh", ":e ~/org/habits.dj<CR>", { desc = "Habits" })
;
; -- Git
; -- map("n", "gs", ":Neogit<CR>", { desc = "Git status" })
; map("n", "<leader>g", ":Neogit<CR>", { desc = "Git status" })
; map("n", "gt", ":Tardis git<CR>", { desc = "Git timemachine (Tardis)" })
; map("n", "g<space>", ":Git ", { desc = "Git" })
; map("n", "gb", function()
;   require("telescope.builtin").git_branches()
; end, { silent = true, desc = "Git branches" })
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
; -- Blogging
; map("n", "gw", function()
;   require("blog.telescope").find_markup()
; end, { desc = "Find blog draft" })
;
; map("n", "z=", function()
;   require("telescope.builtin").spell_suggest()
; end, { silent = true, desc = "Spell suggest" })
; map("n", "<leader>f", function()
;   require("telescope.builtin").find_files()
; end, { silent = true, desc = "Find files" })
; map("n", "<leader>F", function()
;   require("telescope.builtin").find_files({ cwd = vim.fn.expand("%:p:h") })
; end, { silent = true, desc = "Find relative file" })
;
; map("n", "<leader>/", function()
;   require("telescope.builtin").live_grep()
; end, { silent = true, desc = "Find in files" })
; map("n", "<leader>b", function()
;   require("custom.telescope").open_buffer()
; end, { silent = true, desc = "Buffers" })
; map("n", "<leader>o", function()
;   require("telescope.builtin").oldfiles()
; end, { silent = true, desc = "Old files" })
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
; --  Telescoping into a personal knowledge base is really pleasant,
; map("n", "<leader><leader>", function()
;   require("config.org").open_org_file_telescope("")
; end, {
;   desc = "Org",
; })
; map("n", "<leader>ep", function()
;   require("config.org").open_org_file_telescope("projects")
; end, {
;   desc = "Org projects",
; })
; map("n", "<leader>en", function()
;   require("config.org").open_org_file_telescope("notes")
; end, {
;   desc = "Org resources",
; })
; map("n", "<leader>eA", function()
;   require("config.org").open_org_file_telescope("archive")
; end, {
;   desc = "Org archive",
; })
;
; map("n", "<leader>hh", function()
;   require("telescope.builtin").help_tags()
; end, { silent = true, desc = "Help tags" })
;
; -- Ideas
; --require('telescope.builtin').git_commits()
; --require('telescope.builtin').git_bcommits()
; --require('telescope.builtin').git_bcommits_range()
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
