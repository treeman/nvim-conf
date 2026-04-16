(local blog-path (vim.fn.expand "$HOME/code/jonashietala/"))

(fn in-blog [path]
  (= (path:find blog-path 1 true) 1))

(fn is-post [path]
  (= (path:find "posts/" 1 true) 1))

(fn is-draft [path]
  (= (path:find "drafts/" 1 true) 1))

;; Return the relative path of a file by stripping away the `blog_path`.
(fn rel-path [path]
  (if (= (path:find blog-path 1 true) 1)
      (string.sub path (+ (string.len blog-path) 1))
      path))

(fn path-to-url [file-path]
  (local host "localhost:8080/")
  (local rel-file-path (rel-path file-path))
  (if (is-draft rel-file-path)
      (let [slug (rel-file-path:match "drafts/(.+)%.")]
        (.. host "drafts/" slug))
      (is-post rel-file-path)
      (let [(date slug) (rel-file-path:match "posts/(%d%d%d%d%-%d%d%-%d%d)-(.+)%.")]
        (.. host "blog/" (pick-values 1 (date:gsub "-" "/")) "/" slug))))

;; Create a slug from a title.
(fn slugify [title]
  (-> title
      (: :lower)
      (: :gsub "[^ a-zA-Z0-9_-]+" "")
      (: :gsub "[ _]+" "_")
      (: :gsub "^[ _-]+" "")
      (: :gsub "[ _-]+$" "")))

{:blog_path blog-path
 :rel_path rel-path
 :in_blog in-blog
 :is_post is-post
 :is_draft is-draft
 :path_to_url path-to-url
 : slugify}
