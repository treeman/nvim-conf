vim.loader.enable()

-- FIXME this still crashes...
-- Clear Fennel cache when Fennel dependencies are changed.
vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(event)
		if not vim.list_contains({ "update", "install" }, event.data.kind) then
			return
		end

		local name = event.data.spec.name

		if name == "nvim-thyme" or name == "nvim-laurel" then
			require("thyme").setup()
			vim.cmd("ThymeCacheClear")
		end
	end,
	group = vim.api.nvim_create_augroup("init.lua", { clear = true }),
})

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

-- Load the rest of the config with transparent fennel support.
require("config")
