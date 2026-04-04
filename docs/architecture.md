# Architecture Target (Dendritic)

This document defines the target architecture for this repository.

It is intentionally normative: it describes desired end-state patterns, not migration status.

## Caution For Reuse

This repository is personal-first and intentionally opinionated.

Modules may manage application settings declaratively (via `programs.*` and `xdg.configFile.*`). Reusing this configuration can overwrite existing app preferences on a target machine.

Treat module enablement as opting into this repo's defaults.

## Goals

- Keep `flake.nix` thin and focused on composition.
- Move domain ownership into flake modules under `modules/`.
- Keep feature implementation reusable across Home Manager, NixOS, and ad-hoc package use.
- Prefer explicit boundaries over cross-tree implicit wiring.

## Design Principles

- **Flake root is composition glue:** inputs, systems, and top-level module imports only.
- **Modules own outputs:** feature/domain modules emit `flake.*` and/or `perSystem.*`.
- **Per-system first for packages:** build artifacts are exposed from `perSystem.packages`.
- **Integration consumes local outputs:** HM/NixOS modules consume `self.packages` or `self'.packages`, not raw external inputs.
- **Explicit discovery boundaries:** `import-tree` is used only where directory content is homogeneous flake modules.
- **Namespaced options:** avoid generic option trees; keep options under domain/tool namespaces.

## Target Layout

```text
flake.nix
modules/
  <domain>/
    default.nix          # imports feature modules + domain roles
    features/
      <feature>.nix      # owns flake outputs/perSystem outputs for that feature
    roles/
      default.nix        # composes feature modules into role modules
    home-manager/
      <feature>.nix      # HM integration modules (consumers)
    nixos/
      <feature>.nix      # optional NixOS integration modules (consumers)
```

Notes:

- `features/` should contain flake modules only.
- Implementation files are kept outside auto-discovery paths unless they are flake modules themselves.

## Canonical Patterns

### 1) Plain Feature Pattern

Use when a tool only needs straightforward module integration.

- Feature module exports a flake-level HM/NixOS module.
- Integration module enables/configures the program directly.
- No wrapped package is required.

### 2) Wrapped Feature Pattern

Use when configured behavior should be reusable as a package.

- Feature defines a wrapped package in `perSystem.packages.<name>`.
- Feature also exports HM/NixOS integration modules.
- Integration module sets the program package to the wrapped package from `self.packages`.

This is the default pattern for tools that support meaningful configuration and should behave consistently across machines.

In this repo, prefer wrapped features whenever the goal is to keep one reusable tool configuration shared across devices instead of per-host tinkering.

### 3) External Flake Adapter Pattern

Use when integrating outputs from another flake.

- Create a local adapter feature module for that integration.
- Re-export or map external outputs into local `perSystem.packages.<namespace>`.
- Downstream modules consume local outputs, not `inputs.<name>` directly.

### 4) Vendor Package Pattern

Use when software is not available in nixpkgs or as a usable flake.

- Package it locally as a derivation with pinned source + hash when possible.
- Expose it through local feature outputs (preferably `perSystem.packages`).
- Integrate via HM/NixOS modules as consumers.
- If manual source placement is unavoidable, isolate it behind explicit options and keep it outside the default reproducible profile.

## Concrete Example (Implemented)

`tmux` is the reference wrapped-feature shape in this repository:

- wrapped package is defined in `modules/terminal/features/tmux.nix` via `perSystem.packages.terminal-tmux`
- HM integration consumes that package through `modules/terminal/home-manager/tmux.nix`

This is the baseline pattern to replicate for future wrapped tools.

## Input Policy

- Declare needed inputs explicitly in `flake.nix`.
- Prefer `follows` to reduce duplicate dependency trees.
- Do not scan/traverse `inputs` dynamically.
- Avoid coupling implementation modules to flake input topology.

## Documentation References

- flake-parts module-writing best practices:
  - https://flake.parts/best-practices-for-module-writing.html
- flake-parts documentation root:
  - https://flake.parts/
- nix-wrapper-modules getting started:
  - https://birdeehub.github.io/nix-wrapper-modules/md/getting-started.html
- nix-wrapper-modules tmux wrapper module reference:
  - https://birdeehub.github.io/nix-wrapper-modules/wrapperModules/tmux.html
