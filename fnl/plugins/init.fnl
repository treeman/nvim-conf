(require-macros :macros)

;; Capture packs that are updated or installed.
(g! :packs_changed {})

(λ set_pack_changed [name event]
  ;; Maybe there's an easier way of updating a global...?
  (var packs vim.g.packs_changed)
  (tset packs name event)
  (g! :packs_changed packs))

(λ run_build_script [build event]
  (local path event.data.path)
  (vim.notify (.. "Run `" (vim.inspect build) "` for " event.data.spec.name)
              vim.log.levels.INFO)
  (vim.system build {:cwd path}
              (λ [exit_obj]
                (when (not= exit_obj.code 0)
                  ;; If I use `vim.notify` it errors with:
                  ;; vim/_editor.lua:0: E5560: nvim_echo must not be called in a fast event context
                  ;; Simply printing is fine I guess, it doesn't have to be the prettiest solution.
                  (print (vim.inspect build) "failed in" path
                         (vim.inspect exit_obj))))))

(λ call_build_cb [build event]
  (vim.notify (.. "Call build hook for " event.data.spec.name)
              vim.log.levels.INFO)
  (build event))

(λ pack_changed [event]
  (when (vim.list_contains [:update :install] event.data.kind)
    (set_pack_changed event.data.spec.name event)
    (local build (?. event :data :spec :data :build))
    (when build
      (case (type build)
        "string" (run_build_script [build] event)
        "table" (run_build_script build event)
        "function" (call_build_cb build event))))
  false)

(augroup! :plugin_init (au! :PackChanged pack_changed))

(λ transform_spec [spec]
  "Transform a vim.pack spec and move lze arguments into `data`
   and create an `after` hook for simple setup or builds"
  (case spec
    {}
    (do
      ;; Split keys to vim.pack and rest into `data`.
      (local pack_args {})
      (local data_args {})
      (each [k v (pairs spec)]
        (if (vim.list_contains [:src :name :version] k)
            (tset pack_args k v)
            (tset data_args k v)))
      ;; `:setup` needs to know what package to require,
      ;; therefore we use `:on_require`
      (when (and spec.setup (not spec.on_require))
        (error (.. "`:setup` specified without `on_require`: "
                   (vim.inspect spec))))

      (λ after [args]
        (local pack_changed_event (. vim.g.packs_changed args.name))
        (set_pack_changed args.name false)
        ;; Call `setup()` functions if needed.
        (when spec.setup
          (local pkg (require spec.on_require))
          (pkg.setup spec.setup))
        ;; Run `after_build` scripts if a `PackChanged` event
        ;; was run with `install` or `update`.
        (when (and spec.after_build pack_changed_event)
          (spec.after_build args))
        ;; Load user specified `after` if it exists.
        (when spec.after
          (spec.after args)))

      (set data_args.after after)
      (set pack_args.data data_args)
      pack_args)
    ;; Bare strings are valid vim.pack specs too.
    other
    other))

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
