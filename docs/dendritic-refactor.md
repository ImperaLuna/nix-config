# Dendritic Refactor Notes

## Goal

Move the repo from a conventional layered NixOS + Home Manager structure toward a more Dendritic-style layout.

Desired properties:

- top-level composition via `flake-parts`
- module discovery via `import-tree`
- features owned at the flake level instead of buried under `home/` or `hosts/`
- eventual reuse of configured tools as wrapped packages, not only HM modules

This refactor is intentionally incremental.

## What Is Already Done

### Flake Entry Point

`flake.nix` now uses `flake-parts`.

It also has direct explicit inputs for:

- `flake-parts`
- `import-tree`

This means the flake itself is now modular, instead of using only a hand-written `outputs = { ... };` shape.

### Terminal Pilot

`terminal` is the pilot area for the refactor.

Terminal composition is now driven from top-level flake modules under:

- `modules/terminal/features/`
- `modules/terminal/roles/default.nix`
- `modules/terminal/home-manager/`

The active terminal integration is wired from the flake level into Home Manager through:

- `config.flake.modules.homeManager.terminal-role-default`

The old temporary compatibility shim at `home/terminal/default.nix` was removed.

### Validation On Real Machine

`RyzenShine` rebuilt and switched successfully after the terminal refactor.

Spot checks confirmed these tools still work from the HM profile:

- `fish`
- `tmux`
- `bat`
- `eza`
- `lazygit`
- `rg`
- `yazi`
- `codex`

So the terminal pilot is not just theoretical. It has been validated by a successful rebuild.

## What Is Still Old-Style

These areas are still mostly conventional layered modules:

- `home/workstation`
- `home/apps`
- `home/gaming`
- `home/desktop`
- `hosts/*`

Also, `flake.nix` still uses `specialArgs` / `extraSpecialArgs`, so the repo is not fully Dendritic yet.

## Correct `import-tree` Usage In This Repo

Important lesson learned:

`import-tree` should only auto-import flake-level modules, not arbitrary implementation files.

Bad idea:

- recursively importing all of `modules/terminal`
- this accidentally pulled in `modules/terminal/home-manager/*.nix`
- those files are HM implementation modules, not flake-parts modules

Current correct boundary:

- `flake.nix` imports `./modules/terminal/default.nix`
- `modules/terminal/default.nix` uses `import-tree` only for `./features`
- `modules/terminal/roles/default.nix` is imported explicitly

So `import-tree` is used as module discovery for flake-level feature modules, not as a blind recursive import over mixed file types.

## Reference Examples We Looked At

### 1. Vimjoyer Dendritic Home Manager Example

Reference:

- https://www.vimjoyer.com/nix/dendritic-home-manager

What this example shows well:

- very thin `flake.nix`
- `outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);`
- modules emitting flake outputs directly:
  - `flake.nixosConfigurations.*`
  - `flake.nixosModules.*`
  - `flake.homeConfigurations.*`
  - `flake.homeModules.*`

Why it matters:

- this is closer to the "real shape" we want than the current transitional state
- it shows that a file should be a flake module owning outputs, not just "some HM module in a folder"

### 2. Vimjoyer Flake Parts + Wrapped Programs Example

Reference:

- https://www.vimjoyer.com/vid79-parts-wrapped

What this example shows well:

- `flake-parts`
- `import-tree`
- `nix-wrapper-modules`
- one feature owning both:
  - a wrapped package in `perSystem.packages.*`
  - system integration in `flake.nixosModules.*`

Example pattern:

- define wrapped package in `perSystem`
- consume it from NixOS/Home Manager via `self.packages` / `self'.packages`

Why it matters:

- this matches the desired long-term direction for tools like:
  - `tmux`
  - `ghostty`
- it avoids refactoring architecture first and then revisiting every tool later to make it reusable

## Current Best Interpretation Of The Direction

The repo owner wants this:

- configured tools as reusable packages
- usable from Home Manager, NixOS, shells, and potentially other systems

That means the best long-term mix is probably:

- `flake-parts` for top-level architecture
- `import-tree` for module discovery
- `nix-wrapper-modules` selectively for reusable tool wrappers

## Maturity Snapshot (Current State)

Estimated position: about 65-75% of the way to a fully Dendritic shape.

### Already Aligned With Dendritic

- `flake-parts` is active at the flake root
- `import-tree` is used for flake-level feature discovery with explicit boundaries
- terminal features are owned at flake-module level (`modules/terminal/features/*`)
- `tmux` now follows the wrapped-program pattern:
  - feature defines `perSystem.packages.terminal-tmux`
  - Home Manager consumes that package via flake-level integration

### Still Transitional

- `flake.nix` still contains significant host assembly logic
- `specialArgs` / `extraSpecialArgs` are still central to wiring
- non-terminal domains are still mostly layered old-style (`home/*`, `hosts/*`)
- only one wrapperized feature exists so far (`tmux`), not yet a broad repo pattern

### Practical Definition Of "Real Dendritic" For This Repo

- very thin `flake.nix` that mainly imports module trees
- module files own flake outputs directly (`flake.*`, `perSystem.*`)
- domains expose reusable roles/features first, with HM/NixOS integration as consumers
- selective wrapped-program features for tools that should be reusable outside HM

## Dendritic Maturity Checklist

### Phase 1 (Now / Completed)

- [x] flake entry point uses `flake-parts`
- [x] terminal moved to flake-level feature/role composition
- [x] `import-tree` boundaries corrected to avoid importing implementation files
- [x] first wrapped-program pilot completed (`tmux`)

### Phase 2 (Near-Term)

- [ ] migrate one more tool to wrapped-program pattern (`ghostty`)
- [ ] document a standard feature template (plain feature vs wrapped feature)
- [ ] keep reducing logic in `flake.nix` by moving output ownership into modules

### Phase 3 (Target Shape)

- [ ] host definitions become mostly module-owned outputs
- [ ] old layered areas (`home/workstation`, `home/apps`, `home/gaming`, `home/desktop`) are incrementally replaced by feature/role modules
- [ ] `flake.nix` becomes thin composition glue + inputs only

## Recommended Next Steps

### Short Term

1. Do not broadly refactor another large area yet unless needed

### Likely Best Technical Next Step

Run one additional wrapped-program pilot to confirm repeatability.

Best candidates:

- `ghostty` (strong next candidate)

Reason:

- these are clearly "configured tool as package" problems
- they align with the desired long-term direction
- they validate that the `tmux` approach is repeatable, not one-off

## Reference Docs (Additions)

- flake-parts best practices:
  - https://flake.parts/best-practices-for-module-writing.html
- flake-parts docs root:
  - https://flake.parts/
- nix-wrapper-modules tmux module reference:
  - https://birdeehub.github.io/nix-wrapper-modules/wrapperModules/tmux.html

## Rule Of Thumb Going Forward

- use `flake-parts` for architecture
- use `import-tree` for flake-level module discovery
- keep implementation files separate from discovery boundaries
- use `nix-wrapper-modules` selectively for tools that should become reusable wrapped packages

## Good Prompt For A New Session

> Read `docs/dendritic-refactor.md` first. The terminal flake-module refactor is working on `RyzenShine`. The current preferred direction is Dendritic flake modules plus selective `nix-wrapper-modules`, following the Vimjoyer examples. Next I want either README cleanup or a `nix-wrapper-modules` pilot for `tmux` or `ghostty`.
