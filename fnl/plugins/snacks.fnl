(require-macros :macros)

(pack! "https://github.com/folke/snacks.nvim")
(local snacks (require :snacks))
(snacks.setup {:indent {:indent {:enabled true :char "┆"}
                        :scope {:enabled true :only_current true}}
               :scroll {:animate {:duration {:step 15 :total 150}}}
               :explorer {}
               :picker {}})

; Maybe, I dunno... Maybe configure telescope first?
(map! :n :<leader>b #(snacks.picker.buffers))
(map! :n :<leader>f #(snacks.picker.files))
(map! :n :<leader>F #(snacks.picker.files {:cwd (vim.fn.expand "%:p:h")}))
; TODO filter away spell files
(map! :n :<leader>ec #(snacks.picker.files {:cwd (vim.fn.stdpath "config")}))

; Instead of:
; (vim.pack.add [{
;     :src "https://github.com/folke/snacks.nvim"
;     :data {
;       :after (fn [_]
;         (local snacks (require :snacks))
;         (snacks.setup {
;             :indent {
;             :indent {
;                 :enabled true
;                 :char "┆"
;             }
;             :scope {
;                 :enabled true
;                 :only_current true
;             }
;             }
;             :scroll {
;             :animate {
;                 :duration { :step 15 :total 150 }
;             }
;             }
;             :explorer { }
;         })
;       )
;     }
;    }]
;    {
;      :load (fn [p]
;        (local spec (or p.spec.data {}))
;        (set spec.name p.spec.name)
;        (local lze (require :lze))
;        (lze.load spec)
;      )
;      :confirm false
;    }
; )
