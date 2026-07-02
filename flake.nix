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

    # set a dynamic SDDM lockscreen
    # check out https://github.com/Darkkal44/qylock for more information
    qylock = {
      url = "github:Darkkal44/qylock";
      flake = false;
    };

    nova = {
      url = "git+ssh://git@github.com/ImperaLuna/Nova.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    voxtype = {
      url = "github:peteonrails/voxtype/dev";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Browser package consumed by modules/desktop/features/zen.
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # Experimental shells for quick Home Manager package testing.
    dank-material-shell = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
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
          ./modules/_systems/default.nix
          ./modules/terminal/default.nix
          ./modules/apps/default.nix
          ./modules/gaming/default.nix
          ./modules/desktop/default.nix
          ./modules/workstation/default.nix
        ];
      }
    );
}
