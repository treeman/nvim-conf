(local helpers (require :util.helpers))

(local M {})

(fn M.request_diagnostics_curr_buf []
  (let [server (require :blog.server)]
    (server.cast {:id "RefreshDiagnostics"
                  :path (vim.fn.expand "%:p")})))

(fn M.add_diagnostics [msg]
  (each [_ buf (ipairs (helpers.list_buffers))]
    (local buf-name (vim.api.nvim_buf_get_name buf))
    (local buf-diagnostics (. msg buf-name))
    (when buf-diagnostics
      (vim.diagnostic.set (vim.api.nvim_create_namespace :blog) buf buf-diagnostics))))

M
