(local M {})

(fn M.collect_captures [query-str]
  (local query (vim.treesitter.query.parse :djot query-str))
  (local parser (vim.treesitter.get_parser 0 :djot))
  (local res [])
  (each [_ tree (ipairs (parser:trees))]
    (local root (tree:root))
    (each [_ node _ (query:iter_captures root 0)]
      (table.insert res node)))
  res)

(fn M.reparse_and_get_node [node]
  (local (row-start col-start row-end) (vim.treesitter.get_node_range node))
  (local parser (vim.treesitter.get_parser))
  (parser:parse [row-start row-end])
  (vim.treesitter.get_node {:pos [row-start col-start]}))

(fn M.find_node [node node-type]
  (var curr node)
  (while curr
    (if (= (type node-type) :string)
        (when (= (curr:type) node-type)
          (lua "return curr"))
        (= (type node-type) :table)
        (when (. node-type (curr:type))
          (lua "return curr")))
    (set curr (curr:parent))))

(fn M.find_node_from_cursor [node-type args]
  (local opts (doto (or args {}) (tset :lang :djot)))
  (M.find_node (vim.treesitter.get_node opts) node-type))

(fn M.get_range [node start-offset end-offset]
  (local (row-start col-start row-end col-end) (vim.treesitter.get_node_range node))
  (values row-start
          (+ col-start (or start-offset 0))
          row-end
          (- col-end (or end-offset 0))))

(fn M.get_text [node start-offset end-offset]
  (local (row-start col-start row-end col-end) (M.get_range node start-offset end-offset))
  (. (vim.api.nvim_buf_get_text 0 row-start col-start row-end col-end {}) 1))

(fn M.find_block_element_from_cursor []
  (M.find_node_from_cursor {:table_caption true
                            :table_cell true
                            :heading_content true
                            :paragraph true}))

(fn M.inside_block_element [selection]
  (local block (M.find_block_element_from_cursor))
  (and (not= block nil) (vim.treesitter.node_contains block selection)))

(fn filter-nodes-by-row [nodes target-row]
  (local curr-nodes [])
  (each [_ node (ipairs nodes)]
    (local (row-start _ row-end) (vim.treesitter.get_node_range node))
    (when (and (<= row-start target-row) (>= row-end target-row))
      (table.insert curr-nodes node)))
  curr-nodes)

(fn filter-nodes-by-col [nodes target-col]
  (var curr-col-dist nil)
  (var curr-node nil)
  (each [_ node (ipairs nodes)]
    (local (_ col-start _ col-end) (vim.treesitter.get_node_range node))
    ;; Yeah this isn't maybe exact when links wrap multiple lines
    (local target-dist
      (math.min (math.abs (- target-col col-start))
                (math.abs (- target-col col-end))))
    (when (or (not curr-col-dist) (<= target-dist curr-col-dist))
      (set curr-node node)
      (set curr-col-dist target-dist)))
  curr-node)

(fn M.get_nearest_node [nodes]
  ;; (1, 0)-indexed
  (local cursor (vim.api.nvim_win_get_cursor 0))
  (local cursor-row (- (. cursor 1) 1))
  (local cursor-col (. cursor 2))
  (local by-row (filter-nodes-by-row nodes cursor-row))
  (if (= (length by-row) 1)
      (. by-row 1)
      (filter-nodes-by-col by-row cursor-col)))

M
