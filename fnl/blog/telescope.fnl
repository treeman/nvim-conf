(local entry-display (require :telescope.pickers.entry_display))
(local conf (. (require :telescope.config) :values))
(local content (require :blog.content))
(local finders (require :telescope.finders))
(local pickers (require :telescope.pickers))
(local previewers (require :telescope.previewers))
(local sorters (require :telescope.sorters))
(local telescope-utils (require :telescope.utils))

(local M {})

(fn split-prompt [prompt]
  (local tags [])
  (local series [])
  (local title [])
  (local path [])
  (each [word (prompt:gmatch "([^%s]+)")]
    (local fst (word:sub 1 1))
    (if (= fst "@") (table.insert tags (word:sub 2))
        (= fst "#") (table.insert series (word:sub 2))
        (= fst "/") (table.insert path word)
        (table.insert title word)))
  {:tags tags
   :series series
   :path path
   :title (vim.fn.join title " ")})

;; Score a prompt element against an entry element using `sorter`.
;;
;; Prompt elements should be a list of words from the prompt.
;; Every prompted element needs a match, otherwise the entry will get filtered.
;;
;; This function will clamp the score to 0..1, and return -1
;; if it should remove the entry.
(fn score-element [prompt-elements entry-element sorter]
  (if (= prompt-elements nil) 0
      (= (next prompt-elements) nil) 0
      (not entry-element) -1
      (do
        ;; Convert multiple entry values to a string like `tag1:tag2`.
        (local entry
          (if (= (type entry-element) :string) entry-element
              (= (type entry-element) :table) (vim.fn.join entry-element ":")
              entry-element))
        (var total 0)
        (each [_ prompt-element (ipairs prompt-elements)]
          (local score (sorter:scoring_function prompt-element entry))
          ;; Require a match for every element.
          (when (< score 0) (lua "return -1"))
          (set total (+ total score)))
        ;; Clamp score to max 1.
        (/ total (length prompt-elements)))))

(fn score-item-type [item]
  (case item.type
    :Post (if item.is_draft 0 0.1)
    :Project 0.1
    :Game 0.1
    :Standalone (if item.is_draft 0.01 0.11)
    :Series 0.12
    :Projects 0.13
    _ (do
        (vim.notify (.. "Unknown item type: " item.type) vim.log.levels.ERROR)
        0)))

(fn score-date [entry]
  (local entry-date
    (if entry.created (pick-values 1 (string.gsub entry.created "-" ""))
        entry.published (pick-values 1 (string.gsub entry.published "-" ""))
        entry.year (.. (tostring entry.year) "0000")))
  (if (not entry-date) 1
      (do
        ;; Date of my first blog post as a number.
        (local beginning-of-time 20090621)
        ;; Today's date as a number.
        (local today (os.date "%Y%m%d"))
        ;; Place the number on a 0..1 scale, where 1 is today.
        (- 1 (/ (- entry-date beginning-of-time) (- today beginning-of-time))))))

(fn content-sorter [opts]
  (local opts (or opts {}))
  (local fzy-sorter (sorters.get_fzy_sorter opts))
  (sorters.Sorter:new
    {:discard true
     :scoring_function
     (fn [_ prompt-str entry]
       (local prompt (split-prompt prompt-str))
       ;; Score and filter against series, tags, and title separately.
       (var series-score (score-element prompt.series entry.series fzy-sorter))
       (when entry.series
         (set series-score (score-element prompt.series entry.series fzy-sorter)))
       (when (= entry.type :Series)
         (set series-score (score-element prompt.series entry.id fzy-sorter)))
       (when (< series-score 0) (lua "return -1"))
       (local tags-score (score-element prompt.tags entry.tags fzy-sorter))
       (when (< tags-score 0) (lua "return -1"))
       (local path-score (score-element prompt.path entry.path fzy-sorter))
       (when (< path-score 0) (lua "return -1"))
       (local title-score (fzy-sorter:scoring_function prompt.title entry.title))
       (when (< title-score 0) (lua "return -1"))
       (local type-score (score-item-type entry))
       (local date-score (score-date entry))
       ;; Date sorting is only worth 1/10 of the fuzzy scores.
       (+ series-score tags-score title-score (/ date-score 10) type-score))}))

(fn make-series-display [item]
  (local icon "󰉋")
  (local displayer
    (entry-display.create
      {:separator " "
       :items [{:width 2}
               {:width (string.len item.title)}
               {:remaining true}]}))
  (displayer [[icon "TelescopeResultsComment"]
              item.title
              [item.id "TelescopeResultsOperator"]]))

(fn make-post-display [item]
  (local ext (telescope-utils.file_extension item.path))
  (local (icon icon-color)
    (if item.is_draft (values "󰽉" "Function")
        (= ext :dj) (values "󰛓" "TelescopeResultsComment")
        (values "" "TelescopeResultsComment")))
  (local tags
    (if (= (type item.tags) :string) item.tags
        (= (type item.tags) :table) (vim.fn.join item.tags ", ")
        ""))
  (local series (or item.series ""))
  (local displayer
    (entry-display.create
      {:separator " "
       :items [{:width 1}
               {:width (string.len item.title)}
               {:width (string.len item.created)}
               {:width (string.len tags)}
               {:remaining true}]}))
  (displayer [[icon icon-color]
              item.title
              [item.created "TelescopeResultsComment"]
              [tags "TelescopeResultsConstant"]
              [series "TelescopeResultsOperator"]]))

(fn make-projects-display [item]
  (local icon "󰾁")
  (local displayer
    (entry-display.create
      {:separator " "
       :items [{:width 2} {:remaining true}]}))
  (displayer [[icon "TelescopeResultsComment"]
              item.title]))

(fn make-project-display [item]
  (local icon "󰙨")
  (local displayer
    (entry-display.create
      {:separator " "
       :items [{:width 1}
               {:width (string.len item.title)}
               {:remaining true}]}))
  (displayer [[icon "TelescopeResultsComment"]
              item.title
              [(tostring item.year) "TelescopeResultsComment"]]))

(fn make-game-display [item]
  (local icon "")
  (local displayer
    (entry-display.create
      {:separator " "
       :items [{:width 2}
               {:width (string.len item.title)}
               {:width (string.len item.published)}
               {:remaining true}]}))
  (displayer [[icon "TelescopeResultsComment"]
              item.title
              [item.published "TelescopeResultsComment"]
              [item.event "Character"]]))

(fn make-standalone-display [item]
  (local icon "󰾁")
  (local icon-color
    (if item.is_draft "Function" "TelescopeResultsComment"))
  (local displayer
    (entry-display.create
      {:separator " "
       :items [{:width 2} {:remaining true}]}))
  (displayer [[icon icon-color]
              item.title]))

(fn make-display [entry]
  (local item entry.value)
  (case item.type
    :Series (make-series-display item)
    :Post (make-post-display item)
    :Projects (make-projects-display item)
    :Game (make-game-display item)
    :Project (make-project-display item)
    :Standalone (make-standalone-display item)
    _ (vim.notify (.. "Unknown item type: " item.type) vim.log.levels.ERROR)))

(fn M.find_markup [opts]
  (local opts (or opts {}))
  (content.list_markup_content
    (fn [files]
      (: (pickers.new opts
           {:finder (finders.new_table
                      {:results files
                       :entry_maker (fn [entry]
                                      {:display make-display
                                       :ordinal entry
                                       :value entry
                                       ;; Make standard action open `path` on <CR>
                                       :filename entry.path})})
            :sorter (content-sorter opts)
            :previewer (previewers.new_buffer_previewer
                         {:title "Content Preview"
                          :define_preview
                          (fn [self entry]
                            (conf.buffer_previewer_maker entry.value.path self.state.bufnr
                              {:bufname self.state.bufname
                               :winid self.state.winid
                               :preview opts.preview
                               :file_encoding opts.file_encoding}))})})
         :find))))

M
