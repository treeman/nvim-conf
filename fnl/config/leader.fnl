(require-macros :laurel.macros)
(local util (require :util))
(local cybershard (util.cybershard_keyboard?))

(g! :mapleader " ")
(if cybershard
    (g! :maplocalleader "_")
    (g! :maplocalleader "-"))

