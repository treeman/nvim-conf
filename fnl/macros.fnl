; Import and reexport macros from nvim-laurel
; See https://github.com/aileot/nvim-laurel/blob/main/docs/reference.md
(local {: let!
        : g!
        : b!
        : w!
        : t!
        : v!
        : env!
        : map!
        : unmap!
        : <C-u>
        : <Cmd>
        : command!
        : augroup!
        : au!
        : autocmd!
        : feedkeys!
        : set!
        : highlight!} (require :laurel.macros))

(fn dbg! [& args]
  `(print (vim.inspect ,args)))

(fn pack! [spec1 & args]
  "Call vim.pack.add via lze" ; Convert the args list into a table.
  (local opts (let [t {}]
                (each [k v (ipairs args)]
                  (when (= (% k 2) 1)
                    (tset t v (. args (+ k 1)))))
                t)) ; Split args into data arguments and standard arguments for vim.pack. ; vim.pack.add has `src` `name` and `version`. Other keys can be sent through `data`.
  (local pack_args {:src spec1})
  (local data_args {})
  (each [k v (pairs opts)] ; Would be nice to simplify this to a "exist in list" check.
    (if (or (= k :src) (= k :name) (= k :version))
        (tset pack_args k v)
        (tset data_args k v)))
  (set pack_args.data data_args)
  `(vim.pack.add [,pack_args] {; Overrides load and passes to lze, which uses `data` to configure
                               ; loading properties.
                               :load (fn [p#]
                                       (local spec# (or p#.spec.data {}))
                                       (set spec#.name p#.spec.name)
                                       (local lze# (require :lze))
                                       (lze#.load spec#))
                               :confirm false}))

; Annoying to pass :buffer params, this is a shortcut.
(fn bmap! [...]
  (map! `&default-opts {:buffer 0} ...))

{: let!
 : g!
 : b!
 : w!
 : t!
 : v!
 : env!
 : map!
 : bmap!
 : unmap!
 : <C-u>
 : <Cmd>
 : command!
 : augroup!
 : au!
 : autocmd!
 : feedkeys!
 : set!
 : highlight!
 : pack!
 : dbg!}
