;; extends

((sigil
  (sigil_name) @_sigil_name
  (quoted_content) @injection.content)
 (#any-of? @_sigil_name "H" "LVN" "HOLO")
 (#set! injection.language "heex")
 (#set! injection.combined))
