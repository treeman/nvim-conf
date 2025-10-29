local workspace_folders_on_rtp = vim.tbl_map(function(path)
	return { uri = "file://" .. path, name = vim.fs.basename(vim.fs.dirname(path)) }
end, vim.api.nvim_get_runtime_file("fnl", true))

return { workspace_folders = workspace_folders_on_rtp }
