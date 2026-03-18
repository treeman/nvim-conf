-- Couldn't figure out how to use laurel macros with this.
-- Meh.
-- https://github.com/stevearc/oil.nvim/issues/87
vim.api.nvim_create_autocmd("User", {
  pattern = "OilEnter",
  callback = vim.schedule_wrap(function(args)
    local oil = require("oil")
    if vim.api.nvim_get_current_buf() == args.data.buf and oil.get_cursor_entry() then
      oil.open_preview()
    end
  end),
})

vim.api.nvim_create_autocmd("FileType", { pattern = "htmldjango", command = "set ft=html" })

vim.api.nvim_create_autocmd("LspProgress", {
  callback = function(ev)
    local value = ev.data.params.value or {}
    local msg = value.message or "done"

    -- rust analyszer in particular has really long LSP messages so truncate them
    if #msg > 40 then
      msg = msg:sub(1, 37) .. "..."
    end

    -- :h LspProgress
    vim.api.nvim_echo({ { msg } }, false, {
      id = "lsp",
      kind = "progress",
      title = value.title,
      status = value.kind ~= "end" and "running" or "success",
      percent = value.percentage,
    })
  end,
})

-- This wasn't that pretty.
-- require("vim._core.ui2").enable({
--   enable = true, -- Whether to enable or disable the UI.
--   msg = { -- Options related to the message module.
--     ---@type 'cmd'|'msg' Where to place regular messages, either in the
--     ---cmdline or in a separate ephemeral message window.
--     target = "cmd",
--     timeout = 4000, -- Time a message is visible in the message window.
--   },
-- })
--
