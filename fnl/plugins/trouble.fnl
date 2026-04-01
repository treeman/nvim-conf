{1 "folke/trouble.nvim"
 :event ["BufReadPost" "BufNewFile"]
 :opts {:modes {:telescope {:sort ["pos" "filename" "severity" "message"]}
                :quickfix {:sort ["pos" "filename" "severity" "message"]}
                :loclist {:sort ["pos" "filename" "severity" "message"]}
                :todo {:sort ["pos" "filename" "severity" "message"]}
                :cascade {:mode "diagnostics"
                          :filter (fn [items]
                                    (var severity vim.diagnostic.severity.HINT)
                                    (each [_ item (ipairs items)]
                                      (set severity
                                           (math.min severity item.severity)))
                                    (vim.tbl_filter (fn [item]
                                                      (= item.severity severity))
                                                    items))}}}}
