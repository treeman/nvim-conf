(require-macros :macros)

(λ transform_spec [spec]
  "Transform a vim.pack spec and split lze arguments into `data`
   and create an `after` hook if `setup` is specified."
  (case spec
    {} (do
         (local pack_args {})
         (local data_args {})
         (each [k v (pairs spec)]
           (if (vim.list_contains [:src :name :version] k)
               (tset pack_args k v)
               (tset data_args k v)))
         ;; TODO spec.setup and spec.after instead
         (local setup (. spec :setup))
         (local on_require (. spec :on_require))
         (local after (. spec :after))
         (when setup
           (when (not on_require)
             (error (.. "`:setup` specified without `on_require`: "
                        (vim.inspect spec))))
           (when after
             (error (.. "`:setup` specified together with `after`: "
                        (vim.inspect spec))))
           (tset data_args :after
                 (λ []
                   (local pkg (require on_require))
                   (pkg.setup setup))))
         (set pack_args.data data_args)
         pack_args)
    other other))

(λ pack_changed [event]
  "Handle pack changed events and issue build commands."
  (local spec event.data.spec)
  (local build spec.data.build)
  (local path event.data.path)
  (when (and (vim.list_contains [:update :install] event.data.kind) build)
    (vim.notify (.. "Run `" (vim.inspect build) "` for " spec.name)
                vim.log.levels.INFO)
    (vim.system build {:cwd path}
                (λ [exit_obj]
                  (when (= exit_obj.code 0)
                    ;; vim.notify here errors with
                    ;; vim/_editor.lua:0: E5560: nvim_echo must not be called in a fast event context
                    ;; Simply printing is fine I guess, it doesn't have to be the prettiest solution.
                    (print (vim.inspect spec.data.build) "failed in" path
                           (vim.inspect exit_obj)))))))

(augroup! :my-plugins (au! :PackChanged pack_changed))

;; List all files, with absolute paths.
(local paths (-> (vim.fn.stdpath "config")
                 (.. "/fnl/plugins/*")
                 (vim.fn.glob)
                 (vim.split "\n")))

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
                         [specs]
                         (each [_ spec (ipairs mod_res)]
                           (table.insert acc (transform_spec spec)))
                         ;; Can return a string or a single spec.
                         _
                         (table.insert acc (transform_spec mod_res)))
                       acc)
                     acc))))

; (each [_ v (ipairs specs)] (dbg! v))

;; Override loader when adding to let lze handle lazy loading
;; when specified via the `data` attribute.
(vim.pack.add specs {:load (fn [p]
                             (local spec (or p.spec.data {}))
                             (set spec.name p.spec.name)
                             (local lze (require :lze))
                             (lze.load spec))
                     :confirm false})
