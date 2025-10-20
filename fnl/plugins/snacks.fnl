{
    :src "https://github.com/folke/snacks.nvim"
           :after (λ []
                   (local snacks (require :snacks))
                   (snacks.setup {:indent {:indent {:enabled true :char "┆"}
                                           :scope {:enabled true :only_current true}}
                                  :scroll {:animate {:duration {:step 15 :total 150}}}
                                  :explorer {}}))}



