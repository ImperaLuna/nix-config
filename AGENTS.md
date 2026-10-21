# Agent instructions

## Repository workflow

- Work directly on `main` unless a branch or worktree is requested.
- In this repository, commit completed changes because the repository is synchronized across devices.
- Check for uncommitted `flake.lock` changes before starting and preserve intentional updates.
- Push any change you make to remote. 
- git-sync auto-commits dirty files within seconds as "changes from <host>". Commit right after each edit with a descriptive message so git-sync only pushes.

## Building and applying

- Build before switching: `nix build .#nixosConfigurations.<host>.config.system.build.toplevel --no-link`. Evaluate the other hosts when a change touches shared modules.
- Show the package diff before switching: `nvd diff /run/current-system <built path>`.
- On RyzenShine, apply with `sudo nixos-rebuild switch --flake /home/imperaluna/nix-config`. It is passwordless. Only switch after a successful build, and report any failed units from the output.
- If the new generation breaks something, roll back with `sudo nixos-rebuild switch --rollback`.
- `sudo nh clean all --keep-since 7d --keep 3`, `sudo systemctl restart <unit>` and `sudo systemctl reset-failed <unit>` are also passwordless. Anything else needing sudo goes to the user.

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

