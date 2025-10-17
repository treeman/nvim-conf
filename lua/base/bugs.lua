-- Workaround for Neovim 0.11 inserting random characters upon start
-- https://github.com/neovim/neovim/issues/33148#issuecomment-2815035441
local _, vimtermcap = pcall(require, "vim.termcap")
vimtermcap.query = function() end
