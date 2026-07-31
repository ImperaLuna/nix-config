# Agent instructions

## Repository workflow

- Work directly on `main` unless a branch or worktree is requested.
- In this repository, commit completed changes because the repository is synchronized across devices.
- Check for uncommitted `flake.lock` changes before starting and preserve intentional updates.
- Push any change you make to remote. 

## Repository structure

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

