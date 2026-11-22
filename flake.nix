{

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim.url = "github:nix-community/nixvim";

    llm-agents.url = "github:numtide/llm-agents.nix";

    # set a dynamic SDDM lockscreen
    # check out https://github.com/Darkkal44/qylock for more information
    qylock = {
      url = "github:Darkkal44/qylock";
      flake = false;
    };

    # Patched GRUB carousel and theme, built by modules/__hosts/_systems/features/caelestia-grub.nix
    # check out https://github.com/Jvr2022/caelestia-grub for more information
    caelestia-grub = {
      url = "github:Jvr2022/caelestia-grub";
      flake = false;
    };

    # The Nova rebuild (private repo; `upgrade` passes the gh token).
    # Its UI runs a patched Quickshell (Nova's packaging/nix/nova-ui.nix,
    # IMP-262), built from source on Nova's nixpkgs pin. Nova's CI builds
    # it on this PC too, so it is usually in the store already.
    #
    # Keeps its own nixpkgs pin on purpose. Nova's CI runs on this PC and
    # builds each PR against that pin, and main gets the same tree as the PR
    # when it merges, so `upgrade` and nova-auto-update find Nova already
    # built in the store. Following our nixpkgs changed every hash, so each
    # update compiled Nova and all its Rust dependencies again.
    nova-rebuild = {
      url = "github:ImperaLuna/Nova";
      inputs.nova-files.follows = "nova-files";
    };

    # nova-bench, the Nova Files benchmark (private repo, fetched like
    # nova-rebuild). Its NixOS module lets RyzenShine drop the page cache
    # between runs without a password.
    nova-bench = {
      url = "github:ImperaLuna/nova-benchmark";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nova Files, a GPUI file manager, installed through Nova's module.
    # Keeps its own nixpkgs pin on purpose: Nova Files' release-build CI
    # pushes `.#default` to the nova-de cache built against that pin. Making
    # it follow our nixpkgs changed its hash, so every nixpkgs update
    # compiled GPUI and Nova Files here from scratch.
    nova-files = {
      url = "github:ImperaLuna/Nova-Files";
    };

    # Browser package consumed by modules/desktop/features/zen.
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { ... }: {
        imports = [
          ./modules/__hosts/default.nix
          ./modules/parts.nix
          ./modules/home-stack.nix
          ./modules/_experimental/default.nix
          ./modules/__hosts/_systems/default.nix
          ./modules/terminal/default.nix
          ./modules/dev/default.nix
          ./modules/gaming/default.nix
          ./modules/desktop/default.nix
        ];
      }
    );
}
