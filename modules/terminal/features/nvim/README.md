# Neovim quick reference

This is the quick-reference sheet for the Neovim setup in this directory. It
covers the repo-specific mappings from [`_keymaps.nix`](./_keymaps.nix) and the
important plugin mappings from [`_plugins.nix`](./_plugins.nix).

## How to read the keys

- `<leader>` is `Space`; `<leader>gp` means press `Space`, then `g`, then `p`.
- `<localleader>` is `\`.
- Modes: **N** = normal, **I** = insert, **V** = visual, **O** = operator-pending.
- `Ctrl-x` means hold Control and press `x`.
- Press `<leader>` and pause to let Which Key show the available leader mappings.

## Find, search, and buffers

| Keys | Modes | Action |
| --- | --- | --- |
| `<leader>f` | N | Find files |
| `<leader>s` | N | Search text in the project |
| `<leader>R` | N | Open project search and replace |
| `<leader>R` | V | Search and replace using the selection |
| `<leader>b` | N | Find an open buffer |
| `H` | N | Go to the previous buffer |
| `L` | N | Go to the next buffer |

## LSP and code navigation

| Keys | Modes | Action |
| --- | --- | --- |
| `gd` | N | Go to definition through a picker |
| `gr` | N | Find references through a picker |
| `gy` | N | Go to type definition through a picker |
| `K` | N | Show hover documentation |
| `<leader>ls` | N | Find symbols in the current document |
| `<leader>lS` | N | Find symbols across the workspace |
| `<leader>rn` | N | Rename the symbol under the cursor |
| `<leader>ca` | N | Show available code actions |
| `<leader>e` | N | Show the diagnostic for the current line |

## Git

| Keys or command | Modes | Action |
| --- | --- | --- |
| `<leader>g` | N | Open Neogit for status, staging, commits, branches, and pushes |
| `]h` | N | Go to the next changed hunk |
| `[h` | N | Go to the previous changed hunk |
| `<leader>gp` | N | Preview the current hunk |
| `<leader>gw` | N | Toggle the inline word diff |
| `:DiffviewOpen` | Command | Open the working-tree diff view |
| `:DiffviewFileHistory %` | Command | Show history for the current file |
| `:DiffviewClose` | Command | Close Diffview |

Neogit is the main Git entry point. It opens in a dedicated tab so commit
views appear beside the status instead of behind a floating window. Press
`q` once to return from a commit view to status, then again to close Neogit
and return to the file you were editing.

## Flash navigation

Flash labels visible targets with one-character jump labels. Type the requested
search text, then press the label shown on the target.

| Keys | Modes | Action |
| --- | --- | --- |
| `s` | N, V, O | Jump to a visible text match |
| `S` | N, V, O | Select or jump to a Treesitter syntax node |
| `r` | O | Apply the pending operator to a remote Flash target without first moving there |
| `R` | V, O | Search for a Treesitter node and use it as the selection or operator target |

Operator-pending mode starts after an operator such as `d`, `y`, or `c`. For
example, press `d`, then use `r` to choose a remote deletion target.

## Functions, classes, and text objects

| Keys | Modes | Action |
| --- | --- | --- |
| `]f` | N, V, O | Go to the start of the next function |
| `[f` | N, V, O | Go to the start of the previous function |
| `]c` | N, V, O | Go to the start of the next class |
| `[c` | N, V, O | Go to the start of the previous class |
| `af` | V, O | Select around a function |
| `if` | V, O | Select inside a function |
| `ac` | V, O | Select around a class |
| `ic` | V, O | Select inside a class |

The text objects compose with normal Vim operators: `daf` deletes a function,
`yic` yanks the inside of a class, and `vaf` selects a function.

## TODO comments and diagnostics

| Keys | Modes | Action |
| --- | --- | --- |
| `<leader>ct` | N | Put project TODO comments in the quickfix list |
| `]t` | N | Go to the next TODO comment |
| `[t` | N | Go to the previous TODO comment |
| `<leader>e` | N | Show the current line diagnostic |

The TODO search recognizes the configured Todo Comments keywords, including
`TODO`, `FIX`, `HACK`, `WARN`, `PERF`, `NOTE`, and `TEST`.

## Clipboard, selection, and saving

The normal yank and paste keys are intentionally wired to the system clipboard.

| Keys | Modes | Action |
| --- | --- | --- |
| `y` | N, V | Copy to the system clipboard |
| `Y` | N | Copy the line to the system clipboard |
| `p` | N, V | Paste from the system clipboard after the cursor or selection |
| `P` | N, V | Paste from the system clipboard before the cursor or selection |
| `Ctrl-a` | N, I | Select the whole buffer |
| `Esc` | I | Leave insert mode and save the current named, writable file if it changed |

## Completion

These mappings are active while the Blink completion menu is available.

| Keys | Action |
| --- | --- |
| `Ctrl-Space` | Open completion; show or hide documentation when already open |
| `Ctrl-e` | Hide completion |
| `Ctrl-y` | Accept the selected completion |
| `Ctrl-n` / `Ctrl-p` | Select the next / previous completion |
| `Down` / `Up` | Select the next / previous completion |
| `Ctrl-f` / `Ctrl-b` | Scroll documentation down / up |
| `Ctrl-k` | Show or hide the function signature |

The first three mappings are explicitly configured here. The remaining rows
come from Blink's configured `default` keymap preset.

## Surroundings

These Mini Surround mappings work with paired delimiters and surroundings such
as parentheses, brackets, quotes, and tags.

| Keys | Action |
| --- | --- |
| `gza` | Add a surrounding pair |
| `gzd` | Delete a surrounding pair |
| `gzf` | Find the next surrounding pair to the right |
| `gzF` | Find the previous surrounding pair to the left |
| `gzh` | Highlight a surrounding pair |
| `gzr` | Replace a surrounding pair |
| `gzn` | Change how many lines are searched for surroundings |
