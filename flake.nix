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

  outputs = inputs@{ flake-parts, nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } ({ config, ... }: {
      imports = [
        ./modules/parts.nix
        ./modules/home-stack.nix
        ./modules/_experimental/default.nix
        ./modules/system-stack.nix
        ./modules/terminal/default.nix
        ./modules/workstation/default.nix
      ];

      flake =
        let
          mkHost = {
            system,
            hostPath,
            username,
            userConfig,
            homeProfile ? "desktop",
            extraSystemModules ? [ ],
          }:
            nixpkgs.lib.nixosSystem {
              inherit system;
              specialArgs = { inherit inputs; };
              modules = [
                hostPath

                config.flake.nixosModules.home-stack
                {
                  home-manager.extraSpecialArgs = {
                    inherit inputs homeProfile;
                    inherit userConfig;
                  };
                  home-manager.users.${username} = import ./home;
                }
              ] ++ extraSystemModules;
            };
        in {
          nixosConfigurations = {
            RyzenShine = mkHost {
              system = "x86_64-linux";
              hostPath = ./hosts/desktop;
              username = "imperaluna";
              userConfig = ./home/users/imperaluna.nix;
              homeProfile = "desktop";
              extraSystemModules = [
                config.flake.nixosModules.system-stack-desktop
              ];
            };
            DuskNova = mkHost {
              system = "x86_64-linux";
              hostPath = ./hosts/laptop;
              username = "dusknova";
              userConfig = ./home/users/imperaluna.nix;
              homeProfile = "server";
            };
          };
        };
    });
}
