[;; Sources `plugin` and `ftdetect` directories when lazy loading.
 "https://github.com/lumen-oss/rtp.nvim"
 ;; Needed for nvim-thyme inference for command line and smart parens in fennel files.
 {:src "https://github.com/eraserhd/parinfer-rust"
  :build ["cargo" "build" "--release"]}]
