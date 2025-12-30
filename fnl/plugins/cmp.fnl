(require-macros :macros)

(λ in_spell? []
  "In spell treesitter context?"
  (local [row col] (vim.api.nvim_win_get_cursor 0))
  (local captures (vim.treesitter.get_captures_at_pos 0 (- row 1) (- col 1)))
  (var has_spell false)
  (var has_nospell false)
  (each [_ cap (ipairs captures)]
    (case cap.capture
      "spell" (set has_spell true)
      "nospell" (set has_nospell true)))
  (and has_spell (not has_nospell)))

(λ colorful_text [ctx]
  (local menu (require :colorful-menu))
  (menu.blink_components_text ctx))

(λ colorful_highlight [ctx]
  (local menu (require :colorful-menu))
  (menu.blink_components_highlight ctx))

[{:src "https://github.com/ribru17/blink-cmp-spell" :dep_of :blink.cmp}
 {:src "https://github.com/jdrupal-dev/css-vars.nvim" :dep_of :blink.cmp}
 {:src "https://github.com/joelazar/blink-calc" :dep_of :blink.cmp}
 {:src "https://github.com/xzbdmw/colorful-menu.nvim"
  :dep_of :blink.cmp
  :on_require :colorful-menu
  :setup {}}
 {:src "https://github.com/Saghen/blink.cmp"
  :build ["cargo" "build" "--release"]
  :on_require :blink.cmp
  :setup {:keymap {:<C-n> ["select_next" "show" "fallback_to_mappings"]
                   :<C-p> ["select_prev" "show" "fallback_to_mappings"]
                   :<Down> ["select_next" "fallback"]
                   :<Up> ["select_prev" "fallback"]
                   :<Tab> ["select_and_accept" "fallback"]
                   :<Left> ["snippet_backward" "fallback"]
                   :<Right> ["snippet_forward" "fallback"]
                   :<C-b> ["scroll_documentation_up" "fallback"]
                   :<C-f> ["scroll_documentation_down" "fallback"]
                   :<C-Space> ["show" "hide"]
                   :<C-h> ["show_documentation"
                           "hide_documentation"
                           "fallback"]
                   :<C-s> ["show_signature" "hide_signature" "fallback"]}
          :sources {:default ["lsp"
                              "blog"
                              "path"
                              "snippets"
                              "css_vars"
                              "spell"
                              "calc"
                              "buffer"]
                    :providers {:blog {:name "Blog"
                                       :module :blog.blink-cmp
                                       :fallbacks ["buffer" "calc" "spell"]}
                                :spell {:name "Spell"
                                        :module :blink-cmp-spell
                                        :opts {:enable_in_context in_spell?}}
                                :lsp {:fallbacks ["buffer"]}
                                :css_vars {:name "css-vars"
                                           :module :css-vars.blink}
                                :calc {:name "calc" :module "blink-calc"}}}
          ; :fuzzy {:sorts [#(if (not (or (= $1.client_name nil)
          ;                               (= $2.client_name nil)
          ;                               (= $1.client_name $2.client_name)))
          ;                      (do
          ;                        (print (vim.inspect $1))
          ;                        (= $2.client_name "blog")))
          ;                 "exact"
          ;                 "score"
          ;                 "sort_text"]}
          :completion {:documentation {:auto_show true}
                       :menu {:draw {:columns [{1 "label" :gap 1}
                                               ["kind_icon"]
                                               ; ["kind_icon" "kind"]
                                               ["source_name"]]
                                     :components {:label {:text colorful_text
                                                          :highlight colorful_highlight}}}
                              :auto_show true}
                       :ghost_text {:show_with_menu true :enabled true}}}
  :event :InsertEnter}]
