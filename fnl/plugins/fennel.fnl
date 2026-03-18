[{1 "aileot/nvim-thyme"
  :version "^v1.6.0"
  :dependencies ["https://git.sr.ht/~technomancy/fennel"]
  :build ":lua require('thyme').setup(); vim.cmd('ThymeCacheClear')"}
 {1 "aileot/nvim-laurel"
  :build ":lua require('thyme').setup(); vim.cmd('ThymeCacheClear')"}
 {1 "eraserhd/parinfer-rust" :build "cargo build --release"}]
