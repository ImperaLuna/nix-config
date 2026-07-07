# Neovim plugin candidates

This folder keeps Neovim configuration backups and notes for features we may revisit later.

## Candidate plugins

### Completion

- `blink.cmp` — completion engine for code, paths, buffers, and snippets. Likely the next major IDE-feel upgrade.
- `friendly-snippets` — common snippet collection. Useful only after a completion/snippet engine is intentionally configured.

### Formatting and linting

- `conform.nvim` — formatter runner. Candidate use: Python `ruff_format`, maybe other formatters later.
- `nvim-lint` — async lint diagnostics. Candidate use: Python `ruff`; possibly `mypy` only if explicitly wanted.

### Diagnostics and navigation

- `trouble.nvim` — diagnostics/location-list UI for project problems, references, quickfix, and TODO lists.
- `flash.nvim` — fast in-buffer jump/search motions.
- `grug-far.nvim` — project-wide search and replace UI.

### Comments and annotations

- `todo-comments.nvim` — highlights and searches `TODO:`, `FIXME:`, `BUG:`, `NOTE:`, and similar comments.
- `ts-comments.nvim` — Treesitter-aware comment behavior.

### Editing helpers

- `mini.ai` — extra textobjects, complementary to Treesitter textobjects.
- `mini.surround` — add/delete/replace surrounding quotes, brackets, tags.

### Sessions and persistence

- `persistence.nvim` — restore previous session/files after reopening Neovim.

### Lua/Neovim config development

- `lazydev.nvim` — better Lua LSP metadata for editing Neovim config.

## Do not blindly re-add

- `lazy.nvim` — replaced by NixVim/Nix.
- `LazyVim` — intentionally removed so this config stays small and owned.
- `mason.nvim` and `mason-lspconfig.nvim` — Nix should install language tools instead of Neovim downloading them at runtime.
- Theme plugins — only add if we intentionally want that theme again.

## Reintroduction rule

Add one feature at a time. After each plugin:

1. wire minimal config,
2. run `homeswitch`,
3. test the exact behavior in Neovim,
4. keep it only if the behavior is clearly useful.
