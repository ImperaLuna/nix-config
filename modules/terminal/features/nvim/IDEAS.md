# Neovim future improvement ideas

Use this as a parking lot while getting used to the current Neovim setup. Prefer adding one feature at a time after a real missing workflow shows up.

## Current direction

- Keep the setup boring and predictable while learning the muscle memory.
- Avoid features that make saving or leaving insert mode slower or surprising.
- Prefer manual commands first; enable automation only after the behavior feels right.

## Strong next candidates

### `trouble.nvim`

Diagnostics, quickfix, location-list, references, and TODO views in one UI.

Why it is likely worth adding next:

- Existing LSP diagnostics can feed it immediately.
- `todo-comments` can integrate naturally with it.
- It adds project-awareness without changing editing behavior.
- Low external dependency risk.

Possible keymaps:

```text
<leader>xx  Workspace diagnostics
<leader>xX  Buffer diagnostics
<leader>cs  Symbols
<leader>cl  LSP definitions/references/items
<leader>xL  Location list
<leader>xQ  Quickfix list
```

## Useful, but wait for clearer need

### `conform.nvim`

Formatter runner.

Good first shape:

- Add a manual format command/keymap first.
- Avoid format-on-save initially because `<Esc>` now saves from insert mode; format-on-save would mean every insert-mode escape can also format.

Possible keymap:

```text
<leader>cf  Format current buffer
```

Possible first formatter:

```text
Python: ruff_format
```

### `nvim-lint`

Async lint diagnostics.

Good first shape:

- Start with Python `ruff` only if Python lint feedback feels missing.
- Decide whether `ruff` should be provided by Nix/home packages or by plugin auto-install behavior before enabling it.
- Avoid adding `mypy` unless explicitly wanted; it is heavier and more project-policy dependent.

## Defer for now

### `friendly-snippets`

Common snippets collection.

Defer because snippets are only useful after snippet completion is intentionally configured. Current completion is focused on LSP, path, and buffer sources.

### `persistence.nvim`

Session restore across Neovim restarts.

Defer unless reopening projects starts feeling repetitive. Session restore can be convenient, but it can also reopen stale buffers/layouts when a clean start is preferred.
