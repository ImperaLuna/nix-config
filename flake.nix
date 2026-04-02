{
  nixConfig = {
    extra-substituters = [ "https://cache.numtide.com" ];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    llm-agents.url = "github:numtide/llm-agents.nix";

    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    danksearch = {
      url = "github:AvengeMedia/danksearch";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = inputs@{ self, nixpkgs, dms, danksearch, home-manager, llm-agents, zen-browser, ... }:
  let
    system = "x86_64-linux";
    mkHost = { hostPath, username, userConfig, homeProfile ? "desktop" }: nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        hostPath

        dms.nixosModules.dank-material-shell
        dms.nixosModules.greeter

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            inherit inputs homeProfile;
            inherit userConfig;
          };
          home-manager.users.${username} = import ./home;
        }
      ];
    };
  in {
    nixosConfigurations = {
      RyzenShine = mkHost {
        hostPath = ./hosts/desktop;
        username = "imperaluna";
        userConfig = ./home/users/imperaluna.nix;
        homeProfile = "desktop";
      };
      DuskNova = mkHost {
        hostPath = ./hosts/laptop;
        username = "dusknova";
        userConfig = ./home/users/imperaluna.nix;
        homeProfile = "server";
      };
    };
  };
}
