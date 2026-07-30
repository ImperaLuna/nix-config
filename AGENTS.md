# Nix configuration instructions

This repository is `~/nix-config`.
It supports NixOS machines and non-NixOS systems using Nix as a package manager.

## Nix workflow

- Check for uncommitted `flake.lock` changes before starting and preserve intentional updates.
- Do not run `nix search`, `nix build`, or `nixos-rebuild`.
- Suggest rebuild commands for the user to run.
- For a cheap syntax check, use `nix-instantiate --parse <file> >/dev/null`.
- Use `nix eval` only for a single scalar option.
- Keep Nix command output concise.

## Structure

The configuration follows `host → role → feature`.

- `flake.nix` wires the module domains together.
- `modules/__hosts/` contains NixOS hosts, host system roles, and `.users/`.
- `modules/__hosts/_systems/` contains desktop and server NixOS roles.
- `modules/terminal/`, `modules/dev/`, `modules/gaming/`, and `modules/desktop/` contain Home Manager roles.
- `modules/desktop/features/apps/` contains desktop applications.
- `modules/desktop/features/desktop/` contains graphical desktop essentials.
- `modules/_experimental/` is for temporary package tests.
- `modules/_lib/` contains shared helpers and themes.

NixOS modules configure the machine.
Home Manager modules configure the user environment.
Features are enabled or disabled in their role's `default.nix`.
Feature files are discovered by `_lib/import-feature-tree.nix`.

## Commands

```bash
rebuild   # apply the current NixOS configuration
upgrade   # update flake inputs and rebuild
```
