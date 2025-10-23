vim.opt_local.foldmethod = "expr"
vim.opt_local.foldexpr = "nvim_treesitter#foldexpr()"
vim.bo.commentstring = "{%%s%}"

local map = vim.keymap.set

-- Indent list
-- De-indent list
-- o O <CR> (i) auto next list item
-- Cycle list types?
-- Recalculate list numbers
map("n", "<Tab>", function()
	require("djot.task_marker").toggle_task_marker()
end, { buffer = 0, desc = "Toggle list marker" })
map("n", "<leader>rl", function()
	require("djot.lists").reset_list_numbering()
end, { buffer = 0, desc = "Reset list numbering" })

map("n", "<CR>", function()
	require("djot.links").visit_nearest_link()
end, { buffer = 0, desc = "Visit closest link" })
map("v", "<CR>", function()
	require("djot.links").create_link({ link_style = "collapsed_reference" })
end, { buffer = 0, desc = "Create link" })
map({ "o", "x" }, "u", function()
	require("djot.links").select_link_url()
end, { buffer = 0, desc = "Select link url" })
map("n", "<leader>l", function()
	require("djot.links").convert_link()
end, { buffer = 0, desc = "Convert link type" })

map({ "o", "x" }, "ic", function()
	require("djot.table").select_table_cell()
end, { buffer = 0, desc = "Select table cell" })
