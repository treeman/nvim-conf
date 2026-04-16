(local ts (require :djot.treesitter))

(local M {})

(fn find-table-cells []
  (ts.collect_captures "(table_cell) @cell\n"))

(fn M.get_nearest_table_cell []
  (ts.get_nearest_node (find-table-cells)))

(fn M.select_table_cell []
  (local cell (M.get_nearest_table_cell))
  (when cell
    (local (row-start col-start row-end col-end) (ts.get_range cell))
    (vim.api.nvim_buf_set_mark 0 "<" (+ row-start 1) col-start {})
    (vim.api.nvim_buf_set_mark 0 ">" (+ row-end 1) (- col-end 1) {})
    (vim.cmd "normal! gv")))

M
