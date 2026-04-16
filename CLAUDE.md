# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Rebuild

```bash
rebuild
# or
sudo nixos-rebuild switch --flake ~/nix-config#RyzenShine
sudo nixos-rebuild switch --flake ~/nix-config#DuskNova
```

## Architecture

### Mental model: `host -> role -> feature`

- `flake.nix` only wires module domains together — real config lives in `modules/`
- Two module classes: **NixOS modules** (machine/system config) and **Home Manager modules** (user environment)
- Hosts pick role bundles; roles pick features

### Hosts (`modules/__hosts/`)

Two hosts: **RyzenShine** (desktop, user `imperaluna`) and **DuskNova** (server, user `dusknova`).

Each host folder contains:
- `host.nix` — which roles/stacks this host uses (calls `mkHost`)
- `configuration.nix` — host-specific NixOS config
- `hardware.nix` — generated hardware config
- `default.nix` — imports hardware and configuration

`modules/__hosts/default.nix` defines the `mkHost` helper and wires both hosts. `modules/__hosts/common.nix` has shared config (timezone, fonts, keyboard, networking, nix settings).

### Home Manager stacks (`modules/home-stack.nix`)

- `home-desktop` — bundles terminal, apps, gaming, basic-desktop, desktop, workstation, python, experimental
- `home-lab` — bundles terminal, python, experimental

### Domain roles

Each role lives in `modules/<role>/default.nix` and defines a `flake.modules.homeManager.<role>` module that imports its features. Feature modules auto-discovered via `_lib/import-feature-tree.nix`.

Roles: `terminal`, `apps`, `gaming`, `desktop`, `basic-desktop`, `workstation`, `python`, `_experimental`

### System roles (`modules/_systems/`)

- `_systems-role-desktop` — hyprland, input remapping, virtualisation, DMS, remote access, syncthing
- `_systems-role-server` — homelab, remote access

System stack wiring (DMS, greeter) is in `modules/system-stack.nix`.

### Feature pattern

Features register as `flake.modules.homeManager.<role>-feature-<name>`. To disable a feature, comment it out of the role's imports list in `modules/<role>/default.nix` — this removes it from all hosts using that role.

Complex features use a directory with `_module.nix`, `_aliases.nix`, etc. (e.g., `terminal/features/fish/`). Files prefixed with `_` are not auto-imported as standalone features.

### Configuration approaches

**1. Wrapped packages** — for tools supporting config flags, uses [`nix-wrapper-modules`](https://birdeehub.github.io/nix-wrapper-modules/) to bake config into the package. Example: `terminal/features/tmux/default.nix` builds a pre-configured tmux package, then sets `programs.tmux.package` to it.

**2. Home Manager config files** — for apps reading from `~/.config/`. Home Manager writes files via `xdg.configFile` or program options. Some (like Zed) expose `modules.zed.manageSettings = false` to opt out of managed settings.

### Assets

Desktop config files live alongside their feature modules in `modules/desktop/features/<name>/assets/` and are linked via `xdg.configFile` in `default.nix`.

### Scratch area

Use `modules/_experimental/default.nix` for quick package tests.
