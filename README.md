# nix-config

NixOS and Home Manager configuration for my desktop, server, and WSL environments.

## Install

### Install the Nix package manager

NixOS already includes Nix. On Ubuntu, Debian, another Linux distribution, or
WSL, install the multi-user Nix package manager first:

```bash
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon
```

Restart your shell after installation, then clone the repository:

```bash
git clone <repository-url> ~/nix-config
cd ~/nix-config
```

### WSL

WSL uses the standalone Home Manager profile named `Windows`:

```bash
nix run github:nix-community/home-manager -- switch --flake ~/nix-config#Windows
```

This configures the shell, editor, clipboard integration, and Windows Terminal
bindings. Run the command again after changing the configuration.

### Linux server (Ubuntu/Debian/etc.)

This uses the standalone Home Manager profile named `Linux`

```bash
nix run github:nix-community/home-manager -- switch --flake ~/nix-config#Linux
```

Use this for a normal Linux server where you only want the configured user
environment.

### NixOS server

Install NixOS on the machine, copy this repository to it, and check or replace
its hardware configuration. Then apply the server host:

```bash
sudo nixos-rebuild switch --flake ~/nix-config#DuskNova
```

`DuskNova` manages the complete NixOS system and uses the `home-lab` environment.

### Another bare-metal NixOS machine

1. Install NixOS and generate its hardware configuration.
2. Create a directory under `modules/__hosts/`.
3. Add `host.nix`, `configuration.nix`, `hardware.nix`, and `default.nix`.
4. Register the host in `modules/__hosts/default.nix`.
5. Apply it:

```bash
sudo nixos-rebuild switch --flake ~/nix-config#YourHostName
```

Use `RyzenShine` as the desktop example and `DuskNova` as the server example.

## Daily commands

```bash
rebuild   # apply the current NixOS configuration
upgrade   # update flake inputs and rebuild
```

Before changing inputs, check `flake.lock`. Keep lockfile changes intentional.

## Changing features

Features are enabled in the relevant role's `default.nix`. Commenting out a
feature there disables it for every host using that role.

Temporary experiments belong in `modules/_experimental/default.nix`.

## Mental model

The configuration follows:

```text
host → role → feature
```

- `flake.nix` wires everything together.
- `modules/__hosts/` contains machine definitions and host-specific system roles.
- `modules/terminal/` contains portable CLI tools and shells.
- `modules/dev/` contains development tools such as Zed.
- `modules/desktop/` is the desktop entry point. It contains two feature groups:
  - `features/apps/` — applications such as Discord, Spotify, and Obsidian.
  - `features/desktop/` — desktop essentials expected on any graphical PC,
    including Hyprland, Niri, Ghostty, GTK, and related tools.
- `modules/gaming/` contains gaming support.
- `modules/_experimental/` is for temporary package tests.
- `modules/__hosts/.users/` contains per-user settings shared by that user's hosts.
- `modules/_lib/` contains shared module helpers and themes.

System configuration is provided by NixOS modules. User configuration is provided
by Home Manager.
