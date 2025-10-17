(require-macros :macros)

(pack! "https://github.com/folke/snacks.nvim")
(local snacks (require :snacks))
(snacks.setup {:indent {:indent {:enabled true :char "┆"}
                        :scope {:enabled true :only_current true}}
               :scroll {:animate {:duration {:step 15 :total 150}}}
               :explorer {}})

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
