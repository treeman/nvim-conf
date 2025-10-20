(require-macros :macros)

;; List all files, with absolute paths.
(local paths (-> (vim.fn.stdpath "config")
                 (.. "/fnl/plugins/*")
                 (vim.fn.glob)
                 (vim.split "\n")))

(λ transform_spec [spec]
  (case spec
    { } (do
            (local pack_args {})
            (local data_args {})
            (each [k v (pairs spec)]
                (if (vim.list_contains [:src :name :version] k)
                    (tset pack_args k v)
                    (tset data_args k v)))
            (set pack_args.data data_args)
            pack_args)
   other other))

;; Make the paths relative to plugins and remove extension, e.g. "plugins/snacks"
;; and require those packages to get our pack specs.
;; Flattens into a list of specs.
(local specs (accumulate [acc [] _ abs_path (ipairs paths)]
               (do
                  (local path (string.match abs_path "(plugins/[^./]+)%.fnl$"))
                  (if (and path (not= path "plugins/init"))
                    (do
                      (local mod_res (require path))
                      (case mod_res
                        ;; Flatten return if we return a list of specs.
                        [ specs ] (each [_ spec (ipairs mod_res)] (table.insert acc (transform_spec spec)))
                        ;; Can return a string or a single spec.
                        _ (table.insert acc (transform_spec mod_res)))
                      acc)
                    acc))))

; (each [_ v (ipairs specs)] (dbg! v))

;; This is a better way I think, use a transformer instead
;; :src ""
;; :on_plugin :snacks
;; :setup { ... }
;; :build
;; TODO
;; :setup (using :on_plugin) shortcut
;; :build support

;; Override loader when adding to let lze handle lazy loading
;; if specified via the `data` attribute.
(vim.pack.add specs {:load (fn [p]
                             (local spec (or p.spec.data {}))
                             (set spec.name p.spec.name)
                             (local lze (require :lze))
                             (lze.load spec))
                     :confirm false})
