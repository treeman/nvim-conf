{1 "https://github.com/folke/snacks.nvim"
 :lazy false
 :opts {:indent {:indent {:enabled true :char "┆"}
                 :scope {:enabled true :only_current true}}
        :scroll {:animate {:duration {:step 15 :total 150}}}
        :image {}
        :explorer {}
        :terminal {:enabled true}
        :picker {:matcher {:frecency true}
                 :win {:input {:keys {:<Esc> {1 "close" :mode [:i :n]}}}}
                 :formatters {:file {:filename_first true}}}}}
