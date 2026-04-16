(local content (require :blog.content))
(local helpers (require :util.helpers))
(local log ((. (require :plenary.log) :new) {:plugin :blog :level :error}))
(local nio (require :nio))
(local path (require :blog.path))

(local M {})

(fn create-file [title-prompt folder template-fun]
  (nio.run
    (fn []
      (local title (nio.ui.input {:prompt title-prompt}))
      (local template (template-fun title))
      (local file-path (.. path.blog_path folder (path.slugify title) ".dj"))
      (vim.cmd (.. ":e " file-path))
      (vim.api.nvim_buf_set_lines 0 0 0 true template))))

(fn M.new_draft []
  (create-file "Draft title: " "drafts/"
    (fn [title]
      ["---toml"
       (.. "title = \"" title "\"")
       "tags = [\"Some tag\"]"
       "---"])))

(fn M.new_series []
  (create-file "Series title: " "series/"
    (fn [title]
      ["---toml"
       (.. "title = \"" title "\"")
       "completed = false"
       "img = \"/images/trident/nice_wires2.jpg\""
       "homepage = true"
       "---"])))

(fn M.new_static []
  (create-file "Static title: " "static/"
    (fn [title]
      ["---toml"
       (.. "title = \"" title "\"")
       "---"])))

(fn M.new_project []
  (helpers.list_files (.. path.blog_path "projects/")
    (fn [files]
      (var lowest-ordinal 99999)
      (each [_ file (ipairs files)]
        (local ord (tonumber (string.match file "projects/(%d+)")))
        (when (and ord (< ord lowest-ordinal))
          (set lowest-ordinal ord)))
      (local title (nio.ui.input {:prompt "Project title: "}))
      (local template
        ["---toml"
         (.. "title = \"" title "\"")
         (.. "year = " (os.date "%Y"))
         "link = \"\""
         "homepage = true"
         "---"])
      (local file-path
        (.. path.blog_path "projects/"
            (- lowest-ordinal 1) "_"
            (path.slugify title) ".dj"))
      (vim.cmd (.. ":e " file-path))
      (vim.api.nvim_buf_set_lines 0 0 0 true template))))

(fn rename [from to]
  (vim.cmd (.. ":!mv " from " " to))
  (vim.cmd (.. ":e " to)))

(fn M.promote_draft [draft-path]
  (nio.run
    (fn []
      (when (not (path.in_blog draft-path))
        (log.error "Not a blog file:" draft-path)
        (lua "return"))
      (local title (content.extract_title draft-path))
      (local post-path
        (.. path.blog_path "posts/"
            (os.date "%Y-%m-%d") "-"
            (path.slugify title) ".dj"))
      (nio.scheduler)
      (rename draft-path post-path))))

(fn M.promote_curr_draft []
  (M.promote_draft (vim.fn.expand "%:p")))

(fn M.demote_post [post-path]
  (nio.run
    (fn []
      (when (not (path.in_blog post-path))
        (log.error "Not a blog file:" post-path)
        (lua "return"))
      (local title (content.extract_title post-path))
      (local draft-path
        (.. path.blog_path "drafts/" (path.slugify title) ".dj"))
      (nio.scheduler)
      (rename post-path draft-path))))

(fn M.demote_curr_post []
  (M.demote_post (vim.fn.expand "%:p")))

(fn M.open_post_in_browser [file-path]
  (local url (path.path_to_url file-path))
  (when (not url)
    (log.error "Could not convert to url:" file-path)
    (lua "return"))
  (vim.fn.system (.. "xdg-open " url)))

(fn M.open_curr_post_in_browser []
  (M.open_post_in_browser (vim.fn.expand "%:p")))

M
