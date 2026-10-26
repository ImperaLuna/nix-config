# Agent instructions

## Repository workflow

- Work directly on `main` unless a branch or worktree is requested.
- git-sync runs on every machine. Within seconds of any file change it commits whatever is uncommitted as "changes from <host>", then pulls and pushes all local commits.
- Commit your own edits with a descriptive message in the same command as the edit, so git-sync finds nothing left to commit and only pushes your commit. If git-sync gets there first, the change still lands, just under the generic message.
- Never push. git-sync does it.
- Don't commit changes you didn't make, such as a `flake.lock` updated by `upgrade`. git-sync commits those.
- Keep build logs and temp files out of the repo, because git-sync commits anything it finds.

## Building and applying

- Build before switching: `nix build .#nixosConfigurations.<host>.config.system.build.toplevel --no-link`. Evaluate the other hosts when a change touches shared modules.
- Show the package diff before switching: `nix store diff-closures /run/current-system <built path>`.
- On RyzenShine, apply with `sudo nixos-rebuild switch --flake /home/imperaluna/nix-config`. It is passwordless. Only switch after a successful build, and report any failed units from the output.
- If the new generation breaks something, roll back with `sudo nixos-rebuild switch --rollback`.
- Inside the Claude desktop app sudo fails with "no new privileges". Use `systemctl start nixos-apply` and `systemctl start nixos-rollback` instead, without sudo. They block until done. Read the output with `journalctl -u nixos-apply -b --no-pager -n 100`.
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

