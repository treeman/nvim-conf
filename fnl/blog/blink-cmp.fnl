(require-macros :macros)

(local server (require :blog.server))

(local source {})

(fn source.new [_opts]
  (setmetatable {} {:__index source}))

(fn source.enabled [] (server.is_blog_buf))

(λ docs [item]
  ["a" "b"])

; (case (. item :type)
;   :Post (post_docs item)
;   :Standalone (standalone_docs item)
;   :Constant (constant_docs item)
;   :Series (series_docs item)
;   :Tag (tag_docs item)
;   :Img (img_docs item)
;   :Heading (heading_docs item)
;   :LinkDef (link_def_docs item)
;   :BrokenLink (broken_link_docs item)
;   :DivClass (div_class_docs item)))

(fn source.resolve [_self item callback]
  (local lines (docs item))
  (when (and lines (> (length lines) 0))
    (tset item :documentation
          {:kind "markdown" :value (.. (vim.fn.join lines "\n") "\n")}))
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
                             :is_incomplete_forward true}))))

source
