(require-macros :macros)

(command! :BlogStart #(m blog.server start))
(command! :BlogStop #(m blog.server stop))
(command! :BlogRestart #(m blog.server restart))
(command! :BlogReconnect #(m blog.server reconnect))

(command! :BlogNewDraft #(m blog.files new_draft))
(command! :BlogNewSeries #(m blog.files new_series))
(command! :BlogNewStatic #(m blog.files new_static))
(command! :BlogNewProject #(m blog.files new_project))

(command! :BlogPromoteDraft #(m blog.files promote_curr_draft))
(command! :BlogDemotePost #(m blog.files demote_curr_post))

(command! :BlogPreview #(m blog.files open_curr_post_in_browser))
