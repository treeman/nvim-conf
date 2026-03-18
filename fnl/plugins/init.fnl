;; List all files, with absolute paths.
(local paths (-> (vim.fn.stdpath "config")
                 (.. "/fnl/plugins/*")
                 (vim.fn.glob)
                 (vim.split "\n")))

;; Require all files under `plugins/` except this file
;; to generate lua from fennel source.
;; We must do this for lazy to be able to find them (it seems).
(each [_ abs_path (ipairs paths)]
  (do
    (local path (string.match abs_path "(plugins/[^./]+)%.fnl$"))
    (if (and path (not= path "plugins/init"))
        (require path))))

[]
