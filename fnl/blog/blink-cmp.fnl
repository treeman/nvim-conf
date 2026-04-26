(require-macros :macros)

(local server (require :blog.server))
(local snacks (require :snacks))

(local source {})

(fn source.new [_opts]
  (setmetatable {} {:__index source}))

(fn source.enabled [] (server.is_blog_buf))

(fn source.get_trigger_characters [] ["/" "\"" "[" " " "(" "#"])

(fn img-draw [path opts]
  (local buf (opts.window:get_buf))
  (snacks.image.placement.clean buf)
  (local max-height (or (?. opts :config :window :max_height) 30))
  (local max-width (or (?. opts :config :window :max_width) 160))
  (local line (string.rep " " max-width))
  (local lines [])
  (for [_ 1 max-height] (table.insert lines line))
  (vim.api.nvim_buf_set_lines buf 0 -1 false lines)
  (snacks.image.placement.new buf path
                              {:pos [1 0]
                               :range [1 0 max-height 0]
                               :inline true
                               :conceal true}))

(fn source.resolve [_self item callback]
  (local doc-str item.documentation)
  (when doc-str
    (set item.documentation
         {:kind "markdown" :value (.. doc-str "\n")}))
  (when (= item.type :Img)
    (when (not item.documentation)
      (set item.documentation {:kind "markdown" :value ""}))
    (local path (.. (vim.fn.expand "~/code/jonashietala") item.url))
    (set item.documentation.draw (partial img-draw path)))
  (callback item))

(fn source.get_completions [_self ctx callback]
  (local before (string.sub ctx.line 1 (. ctx :cursor 2)))
  (local [row col] ctx.cursor)
  (local path (vim.fn.expand "%:p"))
  (server.call {:id "Complete"
                :path path
                :cursor_before_line before
                :col col
                :row row}
               #(do
                  (local items (?. $1 :completion_items))
                  (callback {:items items
                             :is_incomplete_backward true
                             :is_incomplete_forward true})))
  nil)

source
