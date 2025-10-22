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

(map! "n" "<leader>/" #(: (require :telescope.builtin) :live_grep)
      {:silent true :desc "Find in files"})

(map! "n" "<leader>f" #(: (require :telescope.builtin) :find_files)
      {:silent true :desc "Find files"})

; (map! "n" "<leader>F" #(: (require :telescope.builtin) :find_files
;                           {:cwd (vim.fn.expand "%:p:h")})
;       {:silent true :desc "Find files"})
(map! "n" "<leader>F"
      (λ []
        (local builtin (require :telescope.builtin))
        (builtin.find_files {:cwd (vim.fn.expand "%:p:h")}))
      {:silent true :desc "Find files"})

(map! "n" "<leader>ec"
      #(: (require :telescope.builtin) :find_files
          {:cwd (vim.fn.stdpath "config")})
      {:silent true :desc "Find files"})

(map! "n" "<leader>b" #(: (require :telescope.builtin) :buffers)
      {:silent true :desc "Buffers"})

(map! "n" "<leader>o" #(: (require :telescope.builtin) :oldfiles)
      {:silent true :desc "Old files"})

(map! "n" "gb" #(: (require :telescope.builtin) :git_branches)
      {:silent true :desc "Git branches"})

(map! "n" "z=" #(: (require :telescope.builtin) :spell_suggest)
      {:silent true :desc "Spell suggest"})

(map! "n" "<leader>hh" #(: (require :telescope.builtin) :help_tags)
      {:silent true :desc "Help tags"})

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

; map("n", "gw", function()
;   require("blog.telescope").find_markup()
; end, { desc = "Find blog content" })
;

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
; map("n", "<leader>t", ":Trouble cascade toggle<cr>", { desc = "Diagnostics" })
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
; local old_gx = vim.fn.maparg("gx", "n", nil, true)
; map("n", "gx", require("custom.open").gx_extended(old_gx.callback), { desc = old_gx.desc })

; M.buf_blog = function(buffer)
;   map("n", "<localleader>d", function()
;       require("blog.interaction").goto_def()
;       end, { buffer = buffer, desc = "Goto definition"})
;   map("n", "<localleader>h", require("blog.interaction").hover, { buffer = buffer, desc = "Hover help"})
; end

; M.djot = function()
;   -- FIXME this has stopped working
;   map("n", "<localleader>w", ":Trouble ts_headings toggle<CR>", { buffer = 0, desc = "Display headings"})

;   -- Indent list
;   -- De-indent list
;   -- o O <CR> (i) auto next list item
;   -- Cycle list types?
;   -- Recalculate list numbers
;   map("n", "<Tab>", function()
;       R("org.task_marker").toggle_task_marker()
;       end, { buffer = 0, desc = "Toggle list marker"})
;   map("n", "<leader>rl", function()
;       R("org.lists").reset_list_numbering()
;       end, { buffer = 0, desc = "Reset list numbering"})

;   map("n", "<CR>", function()
;       R("org.links").visit_nearest_link()
;       end, { buffer = 0, desc = "Visit closest link"})
;   map("v", "<CR>", function()
;       R("org.links").create_link({ link_style = "collapsed_reference"})
;       end, { buffer = 0, desc = "Create link"})
;   map({ "o", "x" }, "u", function()
;       R("org.links").select_link_url()
;       end, { buffer = 0, desc = "Select link url"})
;   map("n", "<leader>l", function()
;       R("org.links").convert_link()
;       end, { buffer = 0, desc = "Convert link type"})

;   map({ "o", "x" }, "ic", function()
;       R("org.table").select_table_cell()
;       end, { buffer = 0, desc = "Select table cell"})

;   -- map("n", "<up>", "gk")
;   -- map("n", "<down>", "gj")
; end

; -- Maps four pairs:
; -- [f, [F, ]f, ]F
; -- for the given treesitter textobject
; -- see: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
; local ts_move_keys = {
;                       f = { query = "@function.outer", desc = "goto function" },
;                       a = { query = "@attribute.inner", desc = "goto attribute" },
;                       b = { query = "@block.inner", desc = "goto block" },
;                       c = { query = "@class.outer", desc = "goto class" },
;                       x = { query = "@comment.outer", desc = "goto comment" },
;                       g = { query = { "@class.outer", "@function.outer" }, desc = "goto major" },
;                       -- t = { query = "@heading1", desc = "goto heading1" },}

; M.ts_goto_next_start = {}
; M.ts_goto_next_end = {}
; M.ts_goto_previous_start = {}
; M.ts_goto_previous_end = {}

; for k, v in pairs(ts_move_keys) do
;   M.ts_goto_next_start["]" .. k] = v
;   M.ts_goto_next_end["]" .. string.upper(k)] = v
;   M.ts_goto_previous_start["[" .. k] = v
;   M.ts_goto_previous_end["[" .. string.upper(k)] = v
; end

; -- Some symbolic keymaps that don't have a string.upper()
; M.ts_goto_next_start["]="] = { query = "@statement.outer", desc = "goto statement"}
; M.ts_goto_previous_start["[="] = { query = "@statement.outer", desc = "goto statement"}
; M.ts_goto_next_start["],"] = { query = "@parameter.outer", desc = "goto parameter"}
; M.ts_goto_previous_start["[,"] = { query = "@parameter.outer", desc = "goto parameter"}

; M.ts_swap_next = {
;                   ["<leader>s"] = { query = "@parameter.inner", desc = "Swap next parameter" },}

; M.ts_swap_previous = {
;                       ["<leader>S"] = { query = "@parameter.inner", desc = "Swap previous parameter" },}

; M.ts_select = {
;                ["af"] = { query = "@function.outer", desc = "Select outer function" },
;                ["if"] = { query = "@function.inner", desc = "Select inner function" },
;                ["ac"] = { query = "@class.outer", desc = "Select outer class" },
;                ["ic"] = { query = "@class.inner", desc = "Select inner class" },
;                ["ab"] = { query = "@block.outer", desc = "Select outer block" },
;                ["ib"] = { query = "@block.inner", desc = "Select inner block" },
;                ["aa"] = { query = "@attribute.outer", desc = "Select outer attribute" },
;                ["ia"] = { query = "@attribute.inner", desc = "Seect inner attribute" },
;                ["ax"] = { query = "@comment.outer", desc = "Select outer comment" },
;                ["ix"] = { query = "@comment.inner", desc = "Select inner comment" },
;                ["a="] = { query = "@statement.outer", desc = "Select outer statement" },
;                ["i="] = { query = "@statement.inner", desc = "Select inner statement" },
;                ["a,"] = { query = "@parameter.outer", desc = "Select outer parameter" },
;                ["i,"] = { query = "@parameter.inner", desc = "Select inner parameter" },}

; M.neotest = function(buffer)
;   map("n", "<leader>x", function()
;       require("neotest").run.run()
;       end, { buffer = buffer, desc = "Neotest run test at cursor"})
;   map("n", "<leader>X", function()
;       require("neotest").run.run(vim.fn.expand("%"))
;       end, { buffer = buffer, desc = "Neotest run tests in file"})
;   map("n", "<leader>m", function()
;       require("neotest").run.run(vim.loop.cwd())
;       end, { buffer = buffer, desc = "Neotest run tests in workspace"})

;   map("n", "<leader>n", function()
;       require("neotest").output_panel.toggle()
;       end, { buffer = buffer, desc = "Neotest toggle panel tab"})
;   map("n", "<leader>N", function()
;       require("neotest").summary.toggle()
;       end, { buffer = buffer, desc = "Neotest toggle summary tab"})
; end

; M.buf_lsp = function(_, buffer)
;   -- NOTE there are other cool possibilities listed in nvim-lspconfig
;   map("n", "<localleader>D", vim.lsp.buf.declaration, { silent = true, buffer = buffer, desc = "Declaration"})
;   map("n", "<localleader>d", vim.lsp.buf.definition, { silent = true, buffer = buffer, desc = "Definition"})
;   map("n", "<localleader>r", vim.lsp.buf.references, { silent = true, buffer = buffer, desc = "References"})
;   -- Jumping doesn't quite work, don't switch yet.
;   -- map(
;          --   "n",
;          --   "<localleader>r",
;          --   ":TroubleToggle lsp_references<CR>",
;          --   { silent = true, buffer = buffer, desc = "References"}
;          --)
;   map("n", "<localleader>i", vim.lsp.buf.implementation, { silent = true, buffer = buffer, desc = "Implementation"})
;   map(
;       "n",
;       "<localleader>t",
;       vim.lsp.buf.type_definition,
;       { silent = true, buffer = buffer, desc = "Type definition"})
;
;   map("n", "<localleader>h", vim.lsp.buf.hover, { silent = true, buffer = buffer, desc = "Hover"})
;   map("n", "<localleader>s", vim.lsp.buf.signature_help, { silent = true, buffer = buffer, desc = "Signature help"})
;   map("n", "<localleader>x", vim.lsp.buf.code_action, { silent = true, buffer = buffer, desc = "Code action"})
;   map("n", "<localleader>l", "<cmd>lua vim.diagnostic.open_float({ focusable = false })<CR>")
;   map("n", "<localleader>R", vim.lsp.buf.rename, { silent = true, buffer = buffer, desc = "Rename"})
;   map("n", "<localleader>I", vim.lsp.buf.incoming_calls, { silent = true, buffer = buffer, desc = "Incoming calls"})
;   map("n", "<localleader>O", vim.lsp.buf.outgoing_calls, { silent = true, buffer = buffer, desc = "Outgoing calls"})
;   map(
;       "n",
;       "<localleader>w",
;       ":Trouble symbols toggle<CR>",
;       { silent = true, buffer = buffer, desc = "Document symbols"})
;
; end

; -- These are default bindings in Neovim but they don't open the diagnostic floats immediately.
; -- Calling them manually does though...
; M.global_lsp = function()
;   map("n", "]d", vim.diagnostic.goto_next, { silent = true, desc = "Next diagnostic"})
;   map("n", "[d", vim.diagnostic.goto_prev, { silent = true, desc = "Prev diagnostic"})
; end

; M.gitsigns = function(buffer)
;   local gitsigns = package.loaded.gitsigns
;   map("n", "]h", gitsigns.next_hunk, { silent = true, buffer = buffer, desc = "Next hunk"})
;   map("n", "[h", gitsigns.prev_hunk, { silent = true, buffer = buffer, desc = "Prev hunk"})
;   map("n", "<leader>hs", gitsigns.stage_hunk, { silent = true, buffer = buffer, desc = "Stage hunk"})
;   map("n", "<leader>hr", gitsigns.reset_hunk, { silent = true, buffer = buffer, desc = "Reset hunk"})
;   map("v", "<leader>hs", function()
;       gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v")})
;       end, { silent = true, buffer = buffer, desc = "Stage hunk"})
;   map("v", "<leader>hr", function()
;       gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v")})
;       end, { silent = true, buffer = buffer, desc = "Reset hunk"})
;   map("n", "<leader>hb", function()
;       gitsigns.blame_line({ full = true})
;       end, { silent = true, buffer = buffer, desc = "Blame hunk"})
; end

; M.marks = {
;            set = "m",
;            delete = "dm",
;            delete_line = "dm-",
;            delete_buf = "dm<space>",
;            next = "]m",
;            prev = "[m",
;            preview = "m:",}

; M.pollen = function()
;   map("i", "<C-l>", "λ")
;   map("i", "<C-e>", "◊")
; end
