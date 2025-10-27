(require-macros :macros)

(vim.cmd.colorscheme "melange")

(local bg (: vim.opt.background :get))
(local {: a : b : c : d} (require (.. "melange/palettes/" bg)))

; Adjust for 0.10
(hi! :FloatBorder {:link :WinSeparator})

; snacks.nvim
(hi! :SnacksIndent {:link "IblIndent"})
(hi! :SnacksIndentScope {:link "WinSeparator"})
(hi! :SnacksIndentChunk {:link "WinSeparator"})

; fyler.nvim
(hi! :FylerIndentMarker {:link "IblIndent"})

; Fix neo-tree
(hi! :NeoTreeNormal {:link "Normal"})
(hi! :NeoTreeWinSeparator {:link "WinSeparator"})
(hi! :NeoTreeTitleBar {:link "Normal"})
(hi! :NeoTreeFloatTitle {:link "Conceal"})
(hi! :NeoTreeFloatBorder {:link "WinSeparator"})
(hi! :NeoTreeFloatNormal {:link "NormalFloat"})
(hi! :NeoTreeFadeText1 {:link "LineNr"})
(hi! :NeoTreeFadeText2 {:link "LineNr"})
(hi! :NeoTreeDimText {:link "WinSeparator"})

; Modify nvim-cmp LSP kinds
(hi! :CmpItemAbbrMatch {:link "Function"})
(hi! :CmpItemKindText {:link "Conceal"})
(hi! :CmpItemKindMethod {:link "@lsp.type.method"})
(hi! :CmpItemKindFunction {:link "@lsp.type.function"})
(hi! :CmpItemKindConstructor {:link "@lsp.type.function"})
(hi! :CmpItemKindField {:link "Identifier"})
(hi! :CmpItemKindVariable {:link "@lsp.type.variable"})
(hi! :CmpItemKindClass {:link "@lsp.type.class"})
(hi! :CmpItemKindInterface {:link "@lsp.type.class"})
(hi! :CmpItemKindModule {:link "@lsp.type.namespace"})
(hi! :CmpItemKindProperty {:link "@lsp.type.property"})
(hi! :CmpItemKindUnit {:link "Number"})
(hi! :CmpItemKindValue {:link "Number"})
(hi! :CmpItemKindEnum {:link "@lsp.type.enum"})
(hi! :CmpItemKindKeyword {:link "@lsp.type.keyword"})
(hi! :CmpItemKindSnippet {:link "Number"})
(hi! :CmpItemKindColor {:link "Operator"})
(hi! :CmpItemKindFile {:link "Statement"})
(hi! :CmpItemKindReference {:link "CursorLineNr"})
(hi! :CmpItemKindFolder {:link "Special"})
(hi! :CmpItemKindEnumMember {:link "@lsp.type.enumMember"})
(hi! :CmpItemKindConstant {:link "Constant"})
(hi! :CmpItemKindStruct {:link "@lsp.type.struct"})
(hi! :CmpItemKindEvent {:link "Special"})
(hi! :CmpItemKindOperator {:link "@lsp.type.operator"})
(hi! :CmpItemKindTypeParameter {:link "@lsp.type.typeParameter"})
(hi! :CmpItemMenu {:link "Conceal"})

;; blink.cmp
(hi! :BlinkCmpKindText {:link "Conceal"})
(hi! :BlinkCmpKindMethod {:link "@lsp.type.method"})
(hi! :BlinkCmpKindFunction {:link "@lsp.type.function"})
(hi! :BlinkCmpKindConstructor {:link "@lsp.type.function"})
(hi! :BlinkCmpKindField {:link "Identifier"})
(hi! :BlinkCmpKindVariable {:link "@lsp.type.variable"})
(hi! :BlinkCmpKindClass {:link "@lsp.type.class"})
(hi! :BlinkCmpKindInterface {:link "@lsp.type.class"})
(hi! :BlinkCmpKindModule {:link "@lsp.type.namespace"})
(hi! :BlinkCmpKindProperty {:link "@lsp.type.property"})
(hi! :BlinkCmpKindUnit {:link "Number"})
(hi! :BlinkCmpKindValue {:link "Number"})
(hi! :BlinkCmpKindEnum {:link "@lsp.type.enum"})
(hi! :BlinkCmpKindKeyword {:link "@lsp.type.keyword"})
(hi! :BlinkCmpKindSnippet {:link "Number"})
(hi! :BlinkCmpKindColor {:link "Operator"})
(hi! :BlinkCmpKindFile {:link "Statement"})
(hi! :BlinkCmpKindReference {:link "CursorLineNr"})
(hi! :BlinkCmpKindFolder {:link "Special"})
(hi! :BlinkCmpKindEnumMember {:link "@lsp.type.enumMember"})
(hi! :BlinkCmpKindConstant {:link "Constant"})
(hi! :BlinkCmpKindStruct {:link "@lsp.type.struct"})
(hi! :BlinkCmpKindEvent {:link "Special"})
(hi! :BlinkCmpKindOperator {:link "@lsp.type.operator"})
(hi! :BlinkCmpKindTypeParameter {:link "@lsp.type.typeParameter"})
(hi! :BlinkCmpSource {:link "@comment"})

; I'm annoyed at how the snacks picker looks when it's all `NormalFloat`
(hi! :NormalFloat {:link "Normal"})

; Neotest colors
(hi! :NeotestAdapterName {:link "Conceal"})
(hi! :NeoTestIndent {:link "Conceal"})
(hi! :NeoTestExpandMarker {:link "Conceal"})
; Test hierarchy
(hi! :NeoTestDir {:link "Directory"})
(hi! :NeotestFile {:link "Character"})
(hi! :NeotestNamespace {:link "Statement"})
(hi! :NeotestTest {:link "Identifier"})
; Test status
(hi! :NeotestFailed {:link "DiagnosticError"})
(hi! :NeotestSkipped {:link "Ignore"})
(hi! :NeotestPassed {:link "DiagnosticOk"})
(hi! :NeotestUnknown {:link "DiagnosticHint"})
(hi! :NeotestRunning {:link "Title"})
(hi! :NeotestMarked {:link "Underlined"})
(hi! :NeotestFocused {:link "Special"})
(hi! :NeotestWatching {:link "Number"})
(hi! :NeotestTarget {:link "Type"})
(hi! :NeotestBorder {:link "WinSeparator"})

; nvim-notify
(hi! :NotifyDEBUGBorder {:link "Constant"})
(hi! :NotifyDEBUGIcon {:link "Constant"})
(hi! :NotifyDEBUGTitle {:link "Constant"})
(hi! :NotifyERRORBorder {:link "DiagnosticError"})
(hi! :NotifyERRORIcon {:link "DiagnosticError"})
(hi! :NotifyERRORTitle {:link "DiagnosticError"})
(hi! :NotifyINFOBorder {:link "DiagnosticHint"})
(hi! :NotifyINFOIcon {:link "DiagnosticHint"})
(hi! :NotifyINFOTitle {:link "DiagnosticHint"})
(hi! :NotifyTRACEBorder {:link "DiagnosticInfo"})
(hi! :NotifyTRACEIcon {:link "DiagnosticInfo"})
(hi! :NotifyTRACETitle {:link "DiagnosticInfo"})
(hi! :NotifyWARNBorder {:link "DiagnosticWarn"})
(hi! :NotifyWARNIcon {:link "DiagnosticWarn"})
(hi! :NotifyWARNTitle {:link "DiagnosticWarn"})

; lsp semantic tokens `:help lsp-semantic-highlight`
(hi! "@lsp.typemod.decorator" {:link "Function"})
(hi! "@lsp.type.enumMember" {:link "Constant"})
(hi! "@lsp.mod.documentation" {:link "Statement"})
(hi! "@lsp.mod.readonly" {:link "Constant"})

; Not quite great as MarkSignNumHL overrides current line number coloring
(hi! :MarkSignHL {:link "GitSignsChange"})
(hi! :MarkSignNumHL {:link "LineNr"})

; Markdown
(hi! "@text.reference.markdown_inline" {:link "Type"})
(hi! "@text.reference.markdown" {:link "Type"})
; Djot
(hi! "@markup.heading.1" {:link "Title"})
(hi! "@markup.heading.2" {:link "Constant"})
(hi! "@markup.heading.3" {:link "DiagnosticOk"})
(hi! "@markup.heading.4" {:link "DiagnosticInfo"})
(hi! "@markup.heading.5" {:link "DiagnosticHint"})
(hi! "@markup.heading.6" {:link "DiagnosticError"})
(hi! "@markup.link.url" {:link "@string.special.path"})
(hi! "@markup.highlighted" {:link "Special"})
(hi! "@markup.insert" {:link "@markup.underline"})
(hi! "@markup.superscript" {:link "@string"})
(hi! "@markup.subscript" {:link "@string"})
(hi! "@markup.link.label" {:link "@label"})
(hi! "@markup.link" {:fg c.cyan :underline true})
(hi! "@none" {:link "Normal"})
(hi! "@markup.math" {:link "@markup.italic"})
(hi! "@markup.strikethrough" {:link "@markup.strike"})

; Better elixir colors
(hi! "@symbol.elixir" {:link "@label"})
(hi! "@string.special.symbol.elixir" {:link "@label"})
(hi! "@constant.elixir" {:link "Constant"})

(hi! :MiniTrailSpace {:link "PmenuSel"})

(hi! "@property.beancount" {:link "Number"})
(hi! "@field.beancount" {:link "Function"})
(hi! "@constant.beancount" {:link "Constant"})

(hi! "@attribute" {:link "Constant"})
(hi! :LeapLabelPrimary {:link "IncSearch"})
(hi! :TroubleNormal {:link "Normal"})
(hi! :TroubleNormalNC {:link "Normal"})
