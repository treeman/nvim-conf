(local blog-types
  {:BrokenLink {:rank 0}
   :LinkDef {:rank 1}
   :Heading {:rank 2}
   :Post {:rank 3}
   :Tag {:rank 4}
   :Series {:rank 5}
   :Standalone {:rank 6}
   :Constant {:rank 7}
   :Img {:rank 8}
   :DivClass {:rank 9}
   :Symbol {:rank 10}})

(fn blog-compare [a b]
  (when (not (and (= a.source_id :blog)
                  (= b.source_id :blog)))
    (lua "return nil"))

  (local type-a (. blog-types a.type))
  (local type-b (. blog-types b.type))

  (when (or (= type-a nil) (= type-b nil))
    (lua "return nil"))

  (if (< type-a.rank type-b.rank) (lua "return true")
      (> type-a.rank type-b.rank) (lua "return false"))

  (if (= a.type :Img)
      (> a.modified b.modified)
      (= a.type :Post)
      (> a.created b.created)
      (= a.type :Series)
      (> (. a.posts 1 :created) (. b.posts 1 :created))
      (= a.type :Tag)
      (> (length a.posts) (length b.posts))
      nil))

blog-compare
