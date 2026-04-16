(local ts (require :djot.treesitter))

(local M {})

(fn find-links []
  (ts.collect_captures
    "(inline_link) @link
(full_reference_link) @link
(collapsed_reference_link) @link
(autolink) @link
"))

(fn find-link-defs []
  (ts.collect_captures "(link_reference_definition) @def\n"))

(fn M.get_nearest_link []
  (ts.get_nearest_node (find-links)))

(fn M.get_nearest_link_def []
  (ts.get_nearest_node (find-link-defs)))

(fn visit-url [url]
  ;; If starts with localhost or http:// try to open it in the browser
  (when (or (vim.startswith url "http://")
            (vim.startswith url "https://")
            (vim.startswith url "localhost"))
    (vim.notify (.. "Opening " url) vim.log.levels.INFO)
    (vim.fn.system (.. "xdg-open " url))
    (lua "return"))
  ;; TODO what if we're in the blog context? I'd like to
  ;; convert the url paths to their respective files here.
  (local file-path
    (if (vim.startswith url "/")
        url
        (let [current-file-path (vim.api.nvim_buf_get_name 0)
              current-folder (vim.fn.fnamemodify current-file-path ":h")]
          (.. current-folder "/" url))))
  (vim.notify (.. "Opening " file-path) vim.log.levels.INFO)
  (vim.cmd (.. "edit " file-path)))

(fn find-link-def [link-label]
  (local defs (ts.collect_captures "(link_reference_definition) @def\n"))
  (var result nil)
  (each [_ def (ipairs defs) &until result]
    (local label (ts.get_text (def:named_child 0)))
    (when (= label link-label)
      (set result def)))
  result)

(fn get-link-def-url-range [link-label]
  (local def (find-link-def link-label))
  (when def
    (ts.get_range (def:named_child 1))))

(fn get-link-destination-range [link]
  (case (link:type)
    :inline_link
    (ts.get_range (. (link:field :destination) 1) 1 1)
    :full_reference_link
    (let [label (ts.get_text (. (link:field :label) 1))]
      (get-link-def-url-range label))
    :collapsed_reference_link
    (let [label (ts.get_text (. (link:field :text) 1) 1 1)]
      (get-link-def-url-range label))
    :autolink
    (ts.get_range link 1 1)
    :link_reference_definition
    (ts.get_range (. (link:field :destination) 1))))

(fn get-link-destination [link]
  (local (row-start col-start row-end col-end) (get-link-destination-range link))
  (when row-start
    (. (vim.api.nvim_buf_get_text 0 row-start col-start row-end col-end {}) 1)))

(fn M.visit_nearest_link []
  (local link (M.get_nearest_link))
  (when link
    (local dest (get-link-destination link))
    (if dest
        (visit-url dest)
        (vim.notify (.. "Couldn't find link destination " (link:type))
                    vim.log.levels.ERROR))))

(fn get-visual-range []
  ;; Need to send escape to update visual selection
  (local esc (vim.api.nvim_replace_termcodes "<Esc>" true false true))
  (vim.api.nvim_feedkeys esc :x false)
  (local start-pos (vim.api.nvim_buf_get_mark 0 "<"))
  (local end-pos (vim.api.nvim_buf_get_mark 0 ">"))
  (local last-col (- (vim.fn.col [(. end-pos 1) "$"]) 1))
  ;; Convert from 1- to 0-indexes
  (tset start-pos 1 (- (. start-pos 1) 1))
  (tset end-pos 1 (- (. end-pos 1) 1))
  ;; Need to select past the end
  (tset end-pos 2 (+ (. end-pos 2) 1))
  ;; Sometimes end pos is a very large number way past the ending of the line
  (tset end-pos 2 (math.min (. end-pos 2) last-col))
  [(. start-pos 1) (. start-pos 2) (. end-pos 1) (. end-pos 2)])

(fn is-url [link]
  (if (link:find "^https?://") true false))

(fn transform-url [url]
  (pick-values 1 (url:gsub "^https?://localhost:%d+" "" 1)))

(fn link-url-to-paste []
  (local paste-content (vim.fn.getreg "*" true true))
  (if (not= (length paste-content) 1)
      ""
      (let [link (. paste-content 1)]
        (if (is-url link) (transform-url link) ""))))

(fn change-selection [selection cb]
  (local lines
    (vim.api.nvim_buf_get_text 0
      (. selection 1) (. selection 2) (. selection 3) (. selection 4) {}))
  (local res (cb lines))
  (vim.api.nvim_buf_set_text 0
    (. selection 1) (. selection 2) (. selection 3) (. selection 4) lines)
  res)

(fn create-inline-link [link selection]
  (change-selection selection
    (fn [lines]
      (local res (vim.fn.join lines "\n"))
      (tset lines 1 (.. "[" (. lines 1)))
      (tset lines (length lines) (.. (. lines (length lines)) "](" link ")"))
      res))
  ;; Set cursor at `)`, so we can easily start editing the pasted text if we want to.
  (local end-row (+ (. selection 3) 1))
  ;; End of selection + ]( + link + )
  (local end-col (+ (. selection 4) 2 (length link) 1))
  (vim.api.nvim_win_set_cursor 0 [end-row end-col])
  (when (= link "")
    (vim.cmd :startinsert)))

(fn find-row-to-insert-link-def []
  (local line-count (vim.api.nvim_buf_line_count 0))
  (var has-new-line false)
  (for [i line-count 1 -1]
    (local line (. (vim.api.nvim_buf_get_lines 0 (- i 1) i false) 1))
    (if (and line (not= line ""))
        (do
          (local def
            (ts.find_node_from_cursor :link_reference_definition {:pos [(- i 1) 0]}))
          (vim.notify (vim.inspect def))
          (if def
              (lua "return i")
              has-new-line
              (lua "return (i + 1)")
              (lua "return (i + 2)")))
        (set has-new-line true)))
  line-count)

(fn insert-link-def [label link]
  (local link-def-row (find-row-to-insert-link-def))
  (local line-count (vim.api.nvim_buf_line_count 0))
  (local replacement [(.. "[" label "]: " link)])
  (when (>= link-def-row (+ line-count 2))
    (table.insert replacement 1 ""))
  (vim.api.nvim_buf_set_lines 0 link-def-row link-def-row false replacement))

(fn set-cursor-at-last-content []
  (local line-count (vim.api.nvim_buf_line_count 0))
  (for [i line-count 1 -1]
    (local line (. (vim.api.nvim_buf_get_lines 0 (- i 1) i false) 1))
    (when (and line (not= line ""))
      (vim.api.nvim_win_set_cursor 0 [i 0])
      (lua "break")))
  (vim.cmd "startinsert!"))

(fn create-collapsed-reference-link [link selection]
  (local label
    (change-selection selection
      (fn [lines]
        (local res (vim.fn.join lines "\n"))
        (tset lines 1 (.. "[" (. lines 1)))
        (tset lines (length lines) (.. (. lines (length lines)) "][]"))
        res)))
  (insert-link-def label link)
  (if (= link "")
      ;; If link is empty place cursor at definition and start inserting
      (set-cursor-at-last-content)
      (do
        ;; Set cursor at the end of `][]`.
        (local end-row (+ (. selection 3) 1))
        (local end-col (+ (. selection 4) 3))
        (vim.api.nvim_win_set_cursor 0 [end-row end-col]))))

(fn slugify [title]
  (-> title
      (: :lower)
      (: :gsub "[^ a-zA-Z0-9_-]+" "")
      (: :gsub "[ _]+" "-")
      (: :gsub "^[ _-]+" "")
      (: :gsub "[ _-]+$" "")))

(fn create-full-reference-link [link selection]
  (local label
    (change-selection selection
      (fn [lines]
        (local label (slugify (vim.fn.join lines "\n")))
        (tset lines 1 (.. "[" (. lines 1)))
        (tset lines (length lines) (.. (. lines (length lines)) "][" label "]"))
        label)))
  (insert-link-def label link)
  (if (= link "")
      (set-cursor-at-last-content)
      (do
        (local end-row (+ (. selection 3) 1))
        (local end-col (+ (. selection 4) 3))
        (vim.api.nvim_win_set_cursor 0 [end-row end-col]))))

(fn M.create_link [opts]
  (local opts (vim.tbl_extend :force {:link_style :inline} (or opts {})))
  (local link (link-url-to-paste))
  ;; Only paste in visual selection
  (local mode (. (vim.api.nvim_get_mode) :mode))
  (local is-visual (or (= mode :v) (= mode :V)))
  (when (not is-visual) (lua "return"))
  (local selection (get-visual-range))
  (when (not (ts.inside_block_element selection))
    (vim.notify "Not completely inside a block element" vim.log.levels.DEBUG)
    (lua "return"))
  (case opts.link_style
    :inline (create-inline-link link selection)
    :collapsed_reference (create-collapsed-reference-link link selection)
    :full_reference (create-full-reference-link link selection)))

(fn M.select_link_url []
  (local link (M.get_nearest_link))
  (local (row-start col-start row-end col-end)
    (if link
        (get-link-destination-range link)
        (let [def (M.get_nearest_link_def)]
          (when def
            (get-link-destination-range def)))))
  (when row-start
    (vim.api.nvim_buf_set_mark 0 "<" (+ row-start 1) col-start {})
    (vim.api.nvim_buf_set_mark 0 ">" (+ row-end 1) (- col-end 1) {})
    (vim.cmd "normal! gv")))

(fn remove-link-def [def]
  (local (def-start _ def-end) (vim.treesitter.get_node_range def))
  (vim.api.nvim_buf_set_lines 0 def-start def-end false []))

(fn M.try_create_autolink []
  (local url (vim.fn.expand "<cfile>"))
  (when (not (is-url url)) (lua "return"))
  (local line (vim.api.nvim_get_current_line))
  (local start (line:find url 0 true))
  (when (not start) (lua "return"))
  (local curr-line (- (. (vim.api.nvim_win_get_cursor 0) 1) 1))
  (vim.api.nvim_buf_set_text 0 curr-line (- start 1) curr-line (+ start (length url) -1)
    [(.. "<" url ">")]))

(fn M.convert_link [opts]
  (local opts (vim.tbl_extend :force {:reference_type :collapsed_reference} (or opts {})))
  (local link (M.get_nearest_link))
  (when (not link)
    (M.try_create_autolink)
    (lua "return"))
  (case (link:type)
    :autolink
    (do
      (local destination (ts.get_text link 1 1))
      (local (row-start col-start row-end col-end) (ts.get_range link))
      (vim.api.nvim_buf_set_text 0 row-start col-start row-end col-end
        [(.. "[](" destination ")")])
      (vim.api.nvim_win_set_cursor 0 [(+ row-start 1) (+ col-start 1)])
      (vim.cmd :startinsert))
    :inline_link
    (do
      (local destination (link:named_child 1))
      (local (row-start col-start row-end col-end) (ts.get_range destination 1 1))
      (local dest
        (. (vim.api.nvim_buf_get_text 0 row-start col-start row-end col-end {}) 1))
      (local link-text (ts.get_text (link:named_child 0) 1 1))
      (local label
        (if (= opts.reference_type :collapsed_reference)
            (do
              (vim.api.nvim_buf_set_text 0 row-start (- col-start 1) row-end (+ col-end 1)
                ["[]"])
              link-text)
            (do
              (local slug (slugify link-text))
              (vim.api.nvim_buf_set_text 0 row-start (- col-start 1) row-end (+ col-end 1)
                [(.. "[" slug "]")])
              slug)))
      (insert-link-def label dest))
    _
    (do
      (local (label label-text)
        (if (= (link:type) :collapsed_reference_link)
            (let [l (link:named_child 0)]
              (values l (ts.get_text l 1 1)))
            (let [l (link:named_child 1)]
              (values l (ts.get_text l)))))
      (local def (find-link-def label-text))
      (when (not def)
        (vim.notify (.. "No definition for label: " label-text) vim.log.levels.WARN)
        (lua "return"))
      (local url (ts.get_text (def:named_child 1)))
      ;; First remove the link reference definition.
      (remove-link-def def)
      ;; Then convert to inline link.
      (local (row-start col-start row-end col-end)
        (if (= (link:type) :collapsed_reference_link)
            (let [(rs _ re ce) (ts.get_range link)]
              (values rs (- ce 2) re ce))
            (ts.get_range label -1 -1)))
      (vim.api.nvim_buf_set_text 0 row-start col-start row-end col-end
        [(.. "(" url ")")])
      (vim.cmd :undojoin))))

M
