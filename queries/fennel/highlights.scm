;; extends

(table_pair
  key: (string) @label)

;; nvim-laurel: (let! :bo ...), etc.
(list
  . (symbol) @_call
  (#eq? @_call "let!")
  . (string
      (string_content) @module)
  (#any-of? @module
    "g"
    "b"
    "w"
    "t"
    "v"
    "env"
    "o"
    "go"
    "bo"
    "wo"
    "opt"
    "opt_local"
    "opt_global"))
