{ inputs, config, self, ... }:

let
  mkHost = {
    system,
    hostPath,
    username,
    userConfig,
    homeProfile ? "desktop",
    extraSystemModules ? [ ],
  }:
    let
      homeStackModule =
        if homeProfile == "server"
        then config.flake.nixosModules.home-lab
        else config.flake.nixosModules.home-desktop;
    in
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        hostPath
        homeStackModule
        {
          home-manager.backupFileExtension = "hm-backup";
          home-manager.extraSpecialArgs = {
            inherit inputs homeProfile;
            inherit userConfig;
          };
          home-manager.users.${username} = import ../../modules/home.nix;
        }
      ] ++ extraSystemModules;
    };

  mkHome = {
    system ? "x86_64-linux",
    username,
    homeDirectory,
    userConfig,
    extraModules ? [ ],
  }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      extraSpecialArgs = {
        inherit inputs userConfig;
        homeProfile = "server";
      };

      modules = [
        self.modules.homeManager.terminal
        self.modules.homeManager.dev
        {
          home.username = username;
          home.homeDirectory = homeDirectory;
        }
        ../../modules/home.nix
      ] ++ extraModules;
    };
in
{
  flake.nixosConfigurations =
    (import ./RyzenShine/host.nix { inherit mkHost config; })
    // (import ./DuskNova/host.nix { inherit mkHost config; });

  flake.homeConfigurations =
    import ./Windows/host.nix { inherit mkHome; };
}
