(local ts (require :djot.treesitter))

(fn find-list-marker-line []
  (local task-link-query
    "(list_item (list_marker_task (unchecked)) @unchecked) @list
(list_item (list_marker_task (checked)) @checked) @list
")
  ;; 1-indexed
  (local cursor-row (. (vim.api.nvim_win_get_cursor 0) 1))
  (local query (vim.treesitter.query.parse :djot task-link-query))
  (local parser (vim.treesitter.get_parser))
  (each [_ tree (ipairs (parser:trees))]
    (local root (tree:root))
    (each [_ node _ (query:iter_captures root 0)]
      (when (= (node:type) :list_marker_task)
        ;; 0-indexed
        (local (row-start) (vim.treesitter.get_node_range node))
        (when (= (+ row-start 1) cursor-row)
          (lua "return node"))))))

(fn find-list-marker-up [node]
  (case (node:type)
    :list_marker_task node
    :list_item (let [type-node (node:child 0)]
                 (if (= (type-node:type) :list_marker_task)
                     type-node
                     (let [parent (node:parent)]
                       (when parent (find-list-marker-up parent)))))
    _ (let [parent (node:parent)]
        (when parent (find-list-marker-up parent)))))

(fn find-list-marker []
  (or (find-list-marker-line)
      (let [current (vim.treesitter.get_node)]
        (when current
          (find-list-marker-up current)))))

(fn set-marker [node marker]
  (when (not= (node:type) :list_marker_task)
    (vim.notify (.. "Bad marker! " (node:type)) vim.log.levels.ERROR)
    (lua "return"))
  (local check (node:child 0))
  (local (row-start col-start row-end col-end) (vim.treesitter.get_node_range check))
  (vim.api.nvim_buf_set_text 0 row-start (+ col-start 1) row-end (- col-end 1) [marker]))

(fn get-marker-checkmark [node]
  (when (not= (node:type) :list_marker_task)
    (vim.notify (.. "Bad marker! " (node:type)) vim.log.levels.ERROR)
    (lua "return"))
  (local check (node:child 0))
  (if (= (check:type) :unchecked) " " "x"))

(fn toggle-marker [node]
  (when (not= (node:type) :list_marker_task)
    (vim.notify (.. "Bad marker! " (node:type)) vim.log.levels.ERROR)
    (lua "return"))
  (local mark (if (= (get-marker-checkmark node) :x) " " "x"))
  (set-marker node mark)
  mark)

(fn toggle-markers-inside [node content]
  (if (= (node:type) :list_marker_task)
      (set-marker node content)
      (each [child (node:iter_children)]
        (toggle-markers-inside child content))))

(fn collect-child-markers [list]
  (local res [])
  (each [list-item (list:iter_children)]
    (local list-type (list-item:named_child 0))
    (when (and list-type (= (list-type:type) :list_marker_task))
      (table.insert res (get-marker-checkmark list-type))))
  res)

(fn all-checked [list]
  (var result true)
  (each [_ val (ipairs list) &until (not result)]
    (when (and (not= val :x) (not= val :X))
      (set result false)))
  result)

(fn update-parent-marker [child-marker]
  (local list (ts.find_node child-marker :list))
  (when (not list)
    (vim.notify "Couldn't find list" vim.log.levels.WARN)
    (lua "return"))
  (local marker (find-list-marker-up list))
  (when (not marker) (lua "return"))
  (local markers (collect-child-markers list))
  (if (all-checked markers)
      (set-marker marker :x)
      (set-marker marker " "))
  (local marker (ts.reparse_and_get_node marker))
  (update-parent-marker marker))

(local M {})

(fn M.toggle_task_marker []
  (local parser (vim.treesitter.get_parser))
  (when (not parser) (lua "return"))
  (var marker (find-list-marker))
  (when (not marker)
    (vim.notify "Failed to find task list" vim.log.levels.DEBUG)
    (lua "return"))
  (local checked-value (toggle-marker marker))
  (set marker (ts.reparse_and_get_node marker))
  (when (not marker) (lua "return"))
  (local content (marker:next_sibling))
  (when (and content (= (content:type) :list_item_content))
    (toggle-markers-inside content checked-value))
  (update-parent-marker marker))

M
