(local ts (require :djot.treesitter))

(local M {})

(fn get-marker-type [list]
  (let [first-item (list:child 0)
        marker (first-item:child 0)]
    (marker:type)))

(fn get-order-type [marker-type]
  (local order-types [:decimal :lower_alpha :upper_alpha :lower_roman :upper_roman])
  (var result nil)
  (each [_ order-type (ipairs order-types) &until result]
    (when (string.find marker-type order-type)
      (set result order-type)))
  result)

(fn to-roman [n]
  (local numerals [[1000 "M"] [900 "CM"] [500 "D"] [400 "CD"]
                   [100 "C"] [90 "XC"] [50 "L"] [40 "XL"]
                   [10 "X"] [9 "IX"] [5 "V"] [4 "IV"] [1 "I"]])
  (var num n)
  (var res "")
  (each [_ pair (ipairs numerals)]
    (while (>= num (. pair 1))
      (set res (.. res (. pair 2)))
      (set num (- num (. pair 1)))))
  res)

(fn to-base26 [n]
  (var num n)
  (var res "")
  (while (> num 0)
    (set num (- num 1))
    (local remainder (% num 26))
    (set res (.. (string.char (+ remainder (string.byte "A"))) res))
    (set num (math.floor (/ num 26))))
  res)

(fn get-marker-replacement [i order-type]
  (case order-type
    :decimal (tostring i)
    :lower_alpha (string.lower (to-base26 i))
    :upper_alpha (to-base26 i)
    :lower_roman (string.lower (to-roman i))
    :upper_roman (to-roman i)))

(fn set-list-item-marker [list-item i order-type]
  (local marker (list-item:child 0))
  (local (row-start col-start row-end col-end) (vim.treesitter.get_node_range marker))
  ;; Skip ending `. ` or `) `
  (local col-end (- col-end 2))
  (local marker-text
    (. (vim.api.nvim_buf_get_text 0 row-start col-start row-end col-end {}) 1))
  (local new-marker (get-marker-replacement i order-type))
  (local replacement (string.gsub marker-text "^(%s*%(?).-$" (.. "%1" new-marker)))
  (vim.api.nvim_buf_set_text 0 row-start col-start row-end col-end [replacement])
  (vim.cmd :undojoin))

(fn M.reset_list_numbering []
  (local list (ts.find_node_from_cursor :list))
  (when (not list) (lua "return"))
  (local marker-type (get-marker-type list))
  (local order-type (get-order-type marker-type))
  (when (not order-type) (lua "return"))
  (for [i 1 (list:child_count)]
    (local list-item (list:child (- i 1)))
    (when (not list-item) (lua "break"))
    (set-list-item-marker list-item i order-type)))

M
