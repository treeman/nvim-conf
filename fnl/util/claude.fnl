(local M {})

(var last-style :split)

(fn current-win-for-buf [bufnr]
  (let [wins (vim.fn.win_findbuf bufnr)]
    (. wins 1)))

(fn set-buf-keymaps [bufnr]
  (vim.keymap.set [:n :t] "<C-.>"
                  (fn []
                    (vim.cmd :stopinsert)
                    (vim.api.nvim_win_close (vim.api.nvim_get_current_win)
                                            false))
                  {:buffer bufnr :silent true :desc "Close Claude window"}))

(fn float? [win]
  (let [config (vim.api.nvim_win_get_config win)]
    (and config.relative (not= config.relative ""))))

(fn open-float [bufnr]
  (let [width (math.floor (* vim.o.columns 0.85))
        height (math.floor (* vim.o.lines 0.85))
        row (math.floor (/ (- vim.o.lines height) 2))
        col (math.floor (/ (- vim.o.columns width) 2))]
    (vim.api.nvim_open_win bufnr true
                           {:relative :editor
                            :width width
                            :height height
                            :row row
                            :col col
                            :border :rounded
                            :style :minimal})
    (vim.cmd :startinsert)))

(fn open-split [bufnr]
  (let [width (math.floor (* vim.o.columns 0.4))]
    (vim.cmd (.. "vertical botright sbuffer " bufnr))
    (vim.cmd (.. "vertical resize " width))
    (vim.cmd :startinsert)))

(fn show-in-style [bufnr style]
  (if (= style :float)
      (open-float bufnr)
      (open-split bufnr)))

(fn M.toggle [style]
  (set last-style style)
  (let [terminal (require :claudecode.terminal)
        bufnr (terminal.get_active_terminal_bufnr)]
    (if (and bufnr (vim.api.nvim_buf_is_valid bufnr))
        (do
          (set-buf-keymaps bufnr)
          (let [win (current-win-for-buf bufnr)]
            (if win
                (if (= (float? win) (= style :float))
                    (vim.api.nvim_win_close win false)
                    (do
                      (show-in-style bufnr style)
                      (vim.api.nvim_win_close win false)))
                (show-in-style bufnr style))))
        (do
          (if (= style :float)
              (terminal.simple_toggle {:snacks_win_opts {:position :float
                                                         :width 0.85
                                                         :height 0.85
                                                         :border :rounded}})
              (terminal.simple_toggle {}))
          (let [new-bufnr (terminal.get_active_terminal_bufnr)]
            (when new-bufnr
              (set-buf-keymaps new-bufnr)))))))

(fn M.toggle-last []
  (M.toggle last-style))

M
