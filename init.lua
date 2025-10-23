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

-- FIXME need to do "ThymeCacheClear" after thyme or laurel are updated

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
