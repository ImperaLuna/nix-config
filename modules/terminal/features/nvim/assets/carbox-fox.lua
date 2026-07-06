vim.cmd.highlight("clear")

if vim.fn.exists("syntax_on") == 1 then
  vim.cmd.syntax("reset")
end

vim.o.background = "dark"
vim.g.colors_name = "carbox-fox"

local set = vim.api.nvim_set_hl

set(0, "Normal", { fg = palette.fg, bg = palette.bg })
set(0, "NormalFloat", { fg = palette.fg, bg = palette.bgAlt })
set(0, "CursorLine", { bg = palette.bgAlt })
set(0, "LineNr", { fg = palette.fgAlt })
set(0, "CursorLineNr", { fg = palette.primary, bold = true })
set(0, "Visual", { bg = palette.secondary })
set(0, "Search", { fg = palette.bg, bg = palette.primary })
set(0, "StatusLine", { fg = palette.bg, bg = palette.primary, bold = true })
set(0, "StatusLineNC", { fg = palette.fgDim, bg = palette.bgAlt })

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
