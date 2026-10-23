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

    nova = {
      url = "github:ImperaLuna/nova-shell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.quickshell.follows = "quickshell";
    };

    # Hand nova nixpkgs' quickshell (cached) instead of its own source pin.
    quickshell = {
      url = "path:./modules/_lib/quickshell-nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
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
