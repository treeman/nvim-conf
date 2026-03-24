-- Note: Add a cache path to &rtp. The path MUST include the literal substring "/thyme/compile".
local thyme_cache_prefix = vim.fn.stdpath("cache") .. "/thyme/compiled"
vim.opt.rtp:prepend(thyme_cache_prefix)
-- Note: `vim.loader` internally cache &rtp, and recache it if modified.
vim.loader.enable()

-- https://github.com/aileot/nvim-thyme?tab=readme-ov-file#-installation
local function bootstrap(url)
  -- To manage the version of repo, the path should be where your plugin manager will download it.
  local name = url:gsub("^.*/", "")
  local path = vim.fn.stdpath("data") .. "/lazy/" .. name
  if not vim.loop.fs_stat(path) then
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      url,
      path,
    })
  end
  vim.opt.runtimepath:prepend(path)
end

bootstrap("https://git.sr.ht/~technomancy/fennel")
bootstrap("https://github.com/aileot/nvim-thyme")
bootstrap("https://github.com/folke/lazy.nvim")
-- Copied into repo to make lsp happy.
-- bootstrap("https://github.com/aileot/nvim-laurel")

-- Wrapping the `require` in `function-end` is important for lazy-load.
table.insert(package.loaders, function(...)
  return require("thyme").loader(...) -- Make sure to `return` the result!
end)

-- If you also manage other Fennel macro plugin versions, please clear the Lua cache on the updates!
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyUpdate", -- for lazy.nvim
  callback = function()
    require("thyme").setup()
    vim.cmd("ThymeCacheClear")
  end,
})

-- In init.lua,
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function() -- You can substitute vim.schedule_wrap if you don't mind its tiny overhead.
    vim.schedule(function()
      require("thyme").setup()
    end)
  end,
})

-- Make sure to load leader first.
require("config.leader")

-- Generate fennel source for plugins,
-- not done if we only rely on lazy.
require("plugins")

require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  performance = {
    rtp = {
      reset = false, -- Important! It's unfortunately incompatible with nvim-thyme.
    },
  },
})

-- Load rest of the config with fennel.
require("config")
