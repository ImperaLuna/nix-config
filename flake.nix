{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-wrapper-modules = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    danksearch = {
      url = "github:AvengeMedia/danksearch";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } ({ ... }: {
      imports = [
        ./modules/__hosts/default.nix
        ./modules/parts.nix
        ./modules/home-stack.nix
        ./modules/_experimental/default.nix
        ./modules/_systems/default.nix
        ./modules/system-stack.nix
        ./modules/terminal/default.nix
        ./modules/apps/default.nix
        ./modules/gaming/default.nix
        ./modules/basic-desktop/default.nix
        ./modules/desktop/default.nix
        ./modules/workstation/default.nix
        ./modules/python/default.nix
      ];
    });
}
