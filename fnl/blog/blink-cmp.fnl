(require-macros :macros)

(local server (require :blog.server))
(local snacks (require :snacks))

(local source {})

(fn source.new [_opts]
  (setmetatable {} {:__index source}))

(fn source.enabled [] (server.is_blog_buf))

(fn source.get_trigger_characters [] ["/" "\"" "[" " " "(" "#"])

;; Helpers

(fn read-lines [file start-row end-row res]
  (var linenum 1)
  (each [line (io.lines file) &until (> linenum end-row)]
    (when (and (>= linenum start-row) (<= linenum end-row))
      (table.insert res line))
    (set linenum (+ linenum 1))))

(fn read-post-body [file limit res]
  (var count 1)
  (var frontmatter-delimiters 0)
  (each [line (io.lines file) &until (> count limit)]
    (if (= frontmatter-delimiters 2)
        (do
          (table.insert res line)
          (set count (+ count 1)))
        (string.match line "^%-%-%-")
        (set frontmatter-delimiters (+ frontmatter-delimiters 1)))))

;; Documentation generators

(fn post-docs [post]
  (local tag-line [])
  (each [_ tag (ipairs post.tags)]
    (table.insert tag-line (.. "\"*" tag "*\"")))
  (local res [(.. "`" post.title "`") post.created (vim.fn.join tag-line ", ")])
  (when post.series
    (table.insert res (.. "**" post.series "**")))
  (table.insert res "---")
  (read-post-body post.path 20 res)
  res)

(fn standalone-docs [standalone]
  (local res [(.. "`" standalone.title "`") "---"])
  (read-post-body standalone.path 20 res)
  res)

(fn constant-docs [constant]
  [(.. "`" constant.title "` hardcoded")])

(fn series-docs [series]
  (local res [(.. "`" series.title "` *" series.id "*") "---"])
  (read-post-body series.path 20 res)
  (table.insert res "---")
  (each [_ post (ipairs series.posts)]
    (table.insert res (.. "- **" post.title "**"))
    (table.insert res (.. "  " post.created)))
  res)

(fn tag-docs [tag]
  (local res [(.. (length tag.posts) " tagged `" tag.name "`") "---"])
  (each [_ post (ipairs tag.posts)]
    (table.insert res (.. "- **" post.title "**"))
    (table.insert res (.. "  " post.created)))
  res)

(fn img-docs [img]
  [(.. "`" img.url "`")])

(fn heading-docs [heading]
  (if heading.context.path
      (let [res [(.. "*" heading.context.url "*") "---"]]
        (read-lines heading.context.path heading.context.start_row
                    (+ heading.context.end_row 10) res)
        res)
      (vim.api.nvim_buf_get_lines 0 heading.context.start_row
                                  (+ heading.context.end_row 10) false)))

(fn link-def-docs [def]
  [(.. "[" def.label "]: " def.url)])

(fn broken-link-docs [link]
  (vim.api.nvim_buf_get_lines 0 (- link.row 1) (+ link.row 1) false))

(fn div-class-docs [class]
  (case class.name
    "flex" ["Display images horizontally using flex"
            "---"
            "::: flex"
            "![](/images/one.jpg)"
            "![](/images/two.jpg)"
            ":::"]
    "gallery" ["Create an image gallery"
               "---"
               "::: gallery"
               "![](/images/one.jpg)"
               "![](/images/two.jpg)"
               ":::"]
    "epigraph" ["Convert a blockquote to an epigraph"
                "---"
                "::: epigraph"
                "> The difference between stupidity and genius is that genius has its limits. "
                "> ^ Albert Einstein"
                ":::"]
    "notice" ["Add a text notice" "---" "::: notice" "Highlighted text" ":::"]
    "important"
    ["Add an important notice" "---" "::: important" "Highlighted text" ":::"]
    "update" ["Add a text update"
              "---"
              "{date=\"2024-06-01\"}"
              "::: update"
              "Highlighted text"
              ":::"]
    "greek" ["Use greek characters for ordered list"
             "---"
             "::: greek"
             "a. alpha"
             "b. beta"
             ":::"]
    _ nil))

;; Type dispatch

(fn docs [item]
  (case item.type
    :Post (post-docs item)
    :Standalone (standalone-docs item)
    :Constant (constant-docs item)
    :Series (series-docs item)
    :Tag (tag-docs item)
    :Img (img-docs item)
    :Heading (heading-docs item)
    :LinkDef (link-def-docs item)
    :BrokenLink (broken-link-docs item)
    :DivClass (div-class-docs item)))

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
  (local lines (docs item))
  (when (and lines (> (length lines) 0))
    (set item.documentation
         {:kind "markdown" :value (.. (vim.fn.join lines "\n") "\n")})
    (when (= item.type :Img)
      (local path (.. (vim.fn.expand "~/code/jonashietala") item.url))
      (set item.documentation.draw (partial img-draw path))))
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
