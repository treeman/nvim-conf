;; Taken from
;; https://github.com/julienvincent/config.nvim/blob/418436e0c25d62847a2467158ec95e7c0da0a82e/lua/julienvincent/modules/formatters/injected.lua
;; See: https://julienvincent.io/posts/treesitter-language-injections
;; TODO this just breaks in all my attempts! (:

(local BUFFER_DATA {})

(fn get-buf-opt [buf opt]
  (local map (or (. BUFFER_DATA buf) {}))
  (. map opt))

(fn init-buf [ref-buf opts]
  (local buf (vim.api.nvim_create_buf false true))
  (local offset (or opts.offset 0))
  (local textwidth
    (or (get-buf-opt ref-buf :textwidth)
        (vim.api.nvim_get_option_value :textwidth {:buf ref-buf})
        80))
  (print (vim.inspect [textwidth offset]))
  (local buf-opts
    {:formatoptions (vim.api.nvim_get_option_value :formatoptions {:buf ref-buf})
     :filetype (or opts.ft (vim.api.nvim_get_option_value :filetype {:buf ref-buf}))
     :textwidth (- textwidth offset)
     :shiftwidth 2
     :swapfile false})
  (each [option value (pairs buf-opts)]
    (vim.api.nvim_set_option_value option value {:buf buf}))
  (tset BUFFER_DATA buf {:textwidth buf-opts.textwidth})
  (local buf-name (.. (vim.api.nvim_buf_get_name ref-buf) "." buf "." buf-opts.filetype))
  (vim.api.nvim_buf_set_name buf buf-name)
  buf)

(fn destroy-tmp-buffer [buf]
  (tset BUFFER_DATA buf nil)
  (vim.api.nvim_buf_delete buf {:force true}))

(fn escape-unescaped [str]
  (local (s) (: str :gsub "\\" ""))
  (: s :gsub "\"" "\\\""))

(fn add-offset-indentation [lines offset]
  (var i 0)
  (vim.tbl_map
    (fn [line]
      (set i (+ i 1))
      (if (= i 1) (escape-unescaped line)
          (= line "") line
          (.. (string.rep " " offset) (escape-unescaped line))))
    lines))

(fn trim-end [lines]
  (while (= (. lines (length lines)) "")
    (table.remove lines))
  lines)

(fn []
  (local allowed-languages {:sql true :clojure true :djot true :lua true :fennel true})
  {:format
   (fn [_ ctx lines callback]
     (print "FORMAT")
     (local nio (require :nio))
     (local conform (require :conform))
     (local buf (init-buf ctx.buf {}))
     (vim.api.nvim_buf_set_lines buf 0 -1 false lines)
     (local parser (vim.treesitter.get_parser buf))
     (when (not parser)
       (callback "No TS parser")
       (lua "return"))
     (local range
       (when ctx.range
         [(. ctx.range :start 1) (. ctx.range :start 2)
          (. ctx.range :end 1) (. ctx.range :end 2)]))
     (if range
         (: parser :parse range)
         (: parser :parse true))
     (local format
       (nio.wrap
         (fn [opts cb]
           (conform.format opts
             (fn [err did-edit]
               (cb (and (not err) did-edit)))))
         2))
     (local injections [])
     (each [lang child-tree (pairs (: parser :children))]
       (when (and (. conform.formatters_by_ft lang)
                  (. allowed-languages lang))
         (each [_ region (ipairs (: child-tree :included_regions))]
           (local injection-range
             [(. region 1 1) (. region 1 2) (. region 1 4) (. region 1 5)])
           (local included-in-range
             (and range
                  (>= (. injection-range 1) (. range 1))
                  (<= (. injection-range 4) (. range 4))))
           (when (or (not range) included-in-range)
             (local root (: child-tree :named_node_for_range injection-range))
             (when root
               (let [(sr sc er ec) (root:range)]
                 (table.insert injections
                   {:range [sr sc er ec] :node root :lang lang})))))))
     (local tasks
       (vim.tbl_map
         (fn [injection]
           (fn []
             (local offset (+ (. injection.range 2) 1))
             (local raw-text
               (vim.split (vim.treesitter.get_node_text injection.node buf) "\n"))
             (local tmp-buf (init-buf ctx.buf {:ft injection.lang :offset offset}))
             (vim.api.nvim_buf_set_lines tmp-buf 0 -1 false raw-text)
             (local format-range
               (when range
                 {:start [1 0]
                  :end [(+ (length raw-text) 1)
                        (- (length (. raw-text (length raw-text))) 1)]}))
             (local did-edit (format {:async true :bufnr tmp-buf :range format-range}))
             (when (not did-edit)
               (lua "return nil"))
             (local formatted-lines (vim.api.nvim_buf_get_lines tmp-buf 0 -1 false))
             (destroy-tmp-buffer tmp-buf)
             (local re-indented
               (add-offset-indentation (trim-end formatted-lines) (- offset 1)))
             (when (= (. injection.range 4) 0)
               (table.insert re-indented (string.rep " " (- offset 1))))
             {:lines re-indented :node injection.node :range injection.range}))
         injections))
     (when (= (length tasks) 0)
       (callback nil lines))
     (nio.run
       (fn []
         (local results
           (vim.tbl_filter (fn [result] result) (nio.gather tasks)))
         (when (= (length results) 0)
           (callback nil lines)
           (lua "return"))
         (table.sort results (fn [a b] (> (. a.range 1) (. b.range 1))))
         (each [_ result (ipairs results)]
           (vim.api.nvim_buf_set_text buf
             (. result.range 1) (. result.range 2)
             (. result.range 3) (. result.range 4)
             result.lines))
         (local formatted-lines (vim.api.nvim_buf_get_lines buf 0 -1 false))
         (destroy-tmp-buffer buf)
         (callback nil formatted-lines))
       (fn [success e]
         (when (not success)
           (print e)
           (callback e)))))})
