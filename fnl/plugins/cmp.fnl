{:src "https://github.com/Saghen/blink.cmp"
 :build ["cargo" "build" "--release"]
 :on_require :blink.cmp
 :setup {:keymap {:preset "default"}
         :completion {:documentation {:auto_show true}}
         :sources {:default ["lsp" "path" "snippets" "buffer"]
                   :providers {:blog {:name "blog" :module :blog.blink-cmp}}}
         :keymap {:<C-n> ["select_next" "fallback_to_mappings"]
                  :<C-p> ["select_prev" "fallback_to_mappings"]
                  :<Down> ["select_next" "fallback"]
                  :<Up> ["select_prev" "fallback"]
                  :<Tab> ["select_and_accept" "fallback"]
                  :<Left> ["snippet_backward" "fallback"]
                  :<Right> ["snippet_forward" "fallback"]
                  :<C-b> ["scroll_documentation_up" "fallback"]
                  :<C-f> ["scroll_documentation_down" "fallback"]
                  :<C-Space> ["show" "hide"]
                  :<C-h> ["show_documentation" "hide_documentation" "fallback"]
                  :<C-s> ["show_signature" "hide_signature" "fallback"]}}
 :event :InsertEnter}
