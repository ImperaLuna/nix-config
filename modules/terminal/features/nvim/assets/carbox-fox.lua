vim.cmd.highlight("clear")

if vim.fn.exists("syntax_on") == 1 then
  vim.cmd.syntax("reset")
end

vim.o.background = "dark"
vim.g.colors_name = "carbox-fox"

local set = vim.api.nvim_set_hl

set(0, "Normal", { fg = palette.fg, bg = palette.bg })
set(0, "NormalFloat", { fg = palette.fg, bg = palette.bgAlt })
set(0, "CursorLine", {})
set(0, "LineNr", { fg = palette.fgAlt })
set(0, "CursorLineNr", { fg = palette.primary, bold = true })
set(0, "Visual", { bg = palette.secondary })
set(0, "Search", { fg = palette.bg, bg = palette.primary })
set(0, "FlashLabel", { fg = palette.bg, bg = palette.primary, bold = true })
set(0, "StatusLine", { fg = palette.bg, bg = palette.primary, bold = true })
set(0, "StatusLineNC", { fg = palette.fgDim, bg = palette.bgAlt })
set(0, "TreesitterContext", { fg = palette.fg, bg = palette.bg })
set(0, "TreesitterContextLineNumber", { fg = palette.primary, bg = palette.bg })
set(0, "TreesitterContextSeparator", { fg = palette.primary, bg = palette.bg })

local noiceCmdline = { fg = palette.primary, bg = palette.bg }
local noiceSearch = { fg = palette.secondary, bg = palette.bg }
for _, group in ipairs({
  "NoiceCmdlineIcon",
  "NoiceCmdlineIconCmdline",
  "NoiceCmdlineIconFilter",
  "NoiceCmdlineIconLua",
  "NoiceCmdlineIconHelp",
  "NoiceCmdlineIconInput",
  "NoiceCmdlinePopupBorder",
  "NoiceCmdlinePopupBorderCmdline",
  "NoiceCmdlinePopupBorderFilter",
  "NoiceCmdlinePopupBorderLua",
  "NoiceCmdlinePopupBorderHelp",
  "NoiceCmdlinePopupBorderInput",
  "NoiceCmdlinePopupTitle",
  "NoiceCmdlinePopupTitleCmdline",
  "NoiceCmdlinePopupTitleFilter",
  "NoiceCmdlinePopupTitleLua",
  "NoiceCmdlinePopupTitleHelp",
  "NoiceCmdlinePopupTitleInput",
}) do
  set(0, group, noiceCmdline)
end
for _, group in ipairs({
  "NoiceCmdlineIconSearch",
  "NoiceCmdlinePopupBorderSearch",
  "NoiceCmdlinePopupTitleSearch",
}) do
  set(0, group, noiceSearch)
end

local selectedBuffer = { fg = palette.bg, bg = palette.primary, bold = true, italic = false }
set(0, "BufferLineBufferSelected", selectedBuffer)
set(0, "BufferLineNumbersSelected", selectedBuffer)
set(0, "BufferLineCloseButtonSelected", selectedBuffer)
set(0, "BufferLineDiagnosticSelected", selectedBuffer)
set(0, "BufferLineHintSelected", selectedBuffer)
set(0, "BufferLineInfoSelected", selectedBuffer)
set(0, "BufferLineWarningSelected", selectedBuffer)
set(0, "BufferLineErrorSelected", selectedBuffer)
set(0, "BufferLineModifiedSelected", { fg = palette.bg, bg = palette.primary })
set(0, "BufferLineIndicatorSelected", { fg = palette.bg, bg = palette.primary })
set(0, "BufferLineSeparatorSelected", { fg = palette.primary, bg = palette.bg })

set(0, "Comment", { fg = palette.fgDim, italic = true })
set(0, "String", { fg = palette.success })
set(0, "Number", { fg = palette.info })
set(0, "Boolean", { fg = palette.info })
set(0, "Function", { fg = palette.primary, bold = true })
set(0, "Statement", { fg = palette.secondary })
set(0, "Keyword", { fg = palette.secondary })
set(0, "Type", { fg = palette.primary })
set(0, "Special", { fg = palette.primary })

set(0, "DiagnosticError", { fg = palette.error })
set(0, "DiagnosticWarn", { fg = palette.warning })
set(0, "DiagnosticInfo", { fg = palette.info })
set(0, "DiagnosticHint", { fg = palette.success })

set(0, "GitSignsAdd", { fg = palette.primary })
set(0, "GitSignsChange", { fg = palette.secondary })
set(0, "GitSignsDelete", { fg = palette.error })
set(0, "GitSignsCurrentLineBlame", { fg = palette.fgDim, italic = true })

set(0, "DiffAdd", { fg = palette.primary, bg = palette.bgAlt })
set(0, "DiffChange", { fg = palette.secondary, bg = palette.bgAlt })
set(0, "DiffDelete", { fg = palette.error, bg = palette.bgAlt })
set(0, "DiffText", { fg = palette.bg, bg = palette.primary, bold = true })

set(0, "NeogitDiffAddHighlight", { fg = palette.primary, bg = palette.bgAlt })
set(0, "NeogitDiffDeleteHighlight", { fg = palette.error, bg = palette.bgAlt })
set(0, "NeogitHunkHeader", { fg = palette.primary, bg = palette.bgAlt })
set(0, "NeogitHunkHeaderHighlight", { fg = palette.bg, bg = palette.primary, bold = true })
