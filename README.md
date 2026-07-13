# nix-config

My NixOS setup, organized so I can understand it fast even after a long break.

## 60-second mental model

- `flake.nix` only wires module domains together.
- Real config lives in `modules/`.
- There are 2 module classes:
  - NixOS modules = machine/system config
  - Home Manager modules = user environment config
- Hosts pick role bundles; roles pick features.

In short: `host -> role -> feature`.

## How wiring flows

- Hosts are defined in `modules/__hosts/default.nix`.
- Each NixOS host folder (`modules/__hosts/RyzenShine`, `modules/__hosts/DuskNova`) has
  - `host.nix` (which roles/stacks this host uses)
  - `configuration.nix` (host-specific config)
  - `hardware.nix` (generated hardware config)
- Home Manager-only hosts, such as WSL, can also live under `modules/__hosts/`
  with just a `host.nix`.
- Home Manager stacks are in `modules/home-stack.nix`:
  - `home-desktop` for desktop hosts
  - `home-lab` for server/lab hosts
- The terminal role has a portability seam:
  - `terminal` provides the shell, CLI tools, Neovim, Btop, and Yazi without GUI
    launchers or media-preview packages.
  - `terminal-desktop` layers Ghostty launchers, desktop entries, clipboard support,
    and Yazi's FFmpeg/MPV/Poppler/ImageMagick/Loupe integrations onto `terminal`.
- `home-lab` and standalone `mkHome` profiles use `terminal`; `home-desktop` uses
  `terminal-desktop`.
- System roles are in `modules/_systems/default.nix`.
- Home Manager domain roles are in `modules/*/default.nix` (for example
  `modules/terminal/default.nix`, `modules/desktop/default.nix`,
  `modules/workstation/default.nix`).

## Binary caches and lockfile updates

`flake.nix` advertises the Numtide substituter and signing key, so single-user
Nix installations and trusted users can use the `llm-agents` binary cache.
NixOS hosts also trust the cache at daemon level through
`modules/__hosts/common.nix`.

On a standalone multi-user WSL or VPS installation, cache trust is a restricted
daemon setting. Add the following to `/etc/nix/nix.conf` and restart
`nix-daemon`:

```ini
extra-substituters = https://cache.numtide.com
extra-trusted-public-keys = niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=
```

Normal evaluation and build commands should preserve `flake.lock`. Use
`--no-write-lock-file` for read-only checks. Only intentional input updates,
such as `nix flake update llm-agents`, should rewrite and commit the lockfile.

## Where to enable/disable features

- Edit the role file that includes that feature. One real example:

Disable `yazi` from the terminal role:

```nix
# modules/terminal/default.nix
flake.modules.homeManager.terminal = {
  imports = [
    # ...
    # config.flake.modules.homeManager.terminal-feature-yazi
    # ...
  ];
};
```

That removes `yazi` from every host using the `terminal` HM role.

## Configuration approaches

This config uses two approaches, depending on what each app supports.

### 1) Wrapped package (config baked in)

For tools that support config flags, this repo uses
[`nix-wrapper-modules`](https://birdeehub.github.io/nix-wrapper-modules/) to
build a configured package.

Example: tmux

- `modules/terminal/features/tmux/default.nix` builds a tmux package with
  config baked in and tells Home Manager to install it (`programs.tmux.package`)
- when you run `tmux`, you are running that pre-configured package (no separate
  tmux dotfile needed)

Why this is nice:

- portable: same tmux behavior anywhere that package is installed
- no local tmux dotfile conflicts

Limitations:

- only works cleanly for tools that support config via args/flags
- not every app has a ready-made wrapper module
  ([wrapper list](https://birdeehub.github.io/nix-wrapper-modules/))

### 2) Home Manager writes config files

For apps that read config from fixed paths (like `~/.config/...`) and do not
have a config flag, Home Manager manages the file directly.

Example: Zed (`modules/workstation/features/zed.nix`)

```nix
modules.zed.manageSettings = false;
```

- `true` (default): Home Manager writes Zed settings and desktop entry overrides
- `false`: Zed is still installed, but your local Zed settings are left alone

Why Zed is done this way:

- Zed reads from `~/.config/zed/` at runtime
- there is no clean `--config` style flag path like tmux has

## Scratch area

Use `modules/_experimental/default.nix` for quick package tests.

## Rebuild

```bash
rebuild
```

or:

```bash
sudo nixos-rebuild switch --flake ~/nix-config#RyzenShine
sudo nixos-rebuild switch --flake ~/nix-config#DuskNova
```
