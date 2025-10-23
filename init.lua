vim.loader.enable()

-- vim.pack installs into `~/.local/share/nvim/site/pack/core/opt/` by default
-- while adding them to &runtimepath.
vim.pack.add({
	-- Fennel environment and compiler.
	"https://github.com/aileot/nvim-thyme",
	"https://git.sr.ht/~technomancy/fennel",
	-- Gives us some pleasant fennel macros.
	"https://github.com/aileot/nvim-laurel",
	-- Enables lazy loading of plugins.
	"https://github.com/BirdeeHub/lze",
}, { confirm = false })

-- Override package loading so thyme can hook into `require` calls and generate lua code
-- if the required package is a fennel fil.
table.insert(package.loaders, function(...)
	return require("thyme").loader(...)
end)

-- Setup the compile cache path that thyme requires.
local thyme_cache_prefix = vim.fn.stdpath("cache") .. "/thyme/compiled"
vim.opt.rtp:prepend(thyme_cache_prefix)

vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(event)
		local spec = event.data.spec

		if not spec.data or not spec.data.build then
			return
		end

		if not vim.list_contains({ "update", "install" }, event.data.kind) then
			return
		end

		local path = event.data.path
		local build = spec.data.build

		vim.notify("Run `" .. vim.inspect(build) .. "` for " .. spec.name, vim.log.levels.INFO)

		vim.system(build, { cwd = path }, function(exit_obj)
			if exit_obj.code ~= 0 then
				-- vim.notify here errors with
				-- vim/_editor.lua:0: E5560: nvim_echo must not be called in a fast event context
				-- Simply printing is fine I guess, it doesn't have to be the prettiest solution.
				print(vim.inspect(build), "failed in", path, vim.inspect(exit_obj))
			end
		end)
	end,
	group = vim.api.nvim_create_augroup("init.lua", { clear = true }),
})

-- Load the rest of the config with transparent fennel support.
require("config")
