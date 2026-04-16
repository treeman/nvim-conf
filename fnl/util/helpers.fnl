(local M {})

(fn M.list_buffers []
  (vim.tbl_filter (fn [buf]
                    (and (vim.api.nvim_buf_is_valid buf)
                         (vim.api.nvim_buf_get_option buf :buflisted)))
                  (vim.api.nvim_list_bufs)))

(fn M.file_modified [path]
  (local f (io.popen (.. "stat -c %Y " path)))
  (when f
    (tonumber (f:read))))

(fn M.run_cmd [args]
  (local nio (require :nio))
  (local proc (nio.process.run args))
  (when proc
    (local err (proc.stderr.read))
    (if (and err (not= (string.len err) 0))
        (do
          (vim.notify (.. "error while running command " (vim.inspect args)
                          ": " err) vim.log.levels.ERROR)
          nil)
        (proc.stdout.read))))

(fn M.list_files [path cb]
  (local nio (require :nio))
  (nio.run (fn []
             (local output (M.run_cmd {:cmd "fd" :args ["-t" "f" "\\." path]}))
             (when output
               (nio.scheduler)
               (local files (vim.fn.split output "\n"))
               (cb files)))))

M
