{ inputs, config, self, ... }:

let
  mkHost = {
    system,
    hostPath,
    username,
    userConfig,
    extraSystemModules ? [ ],
  }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        hostPath
        config.flake.nixosModules.home-desktop
        ({ pkgs, ... }: {
          home-manager.backupCommand = pkgs.writeShellScript "home-manager-backup" ''
            target="$1"
            timestamp="$(${pkgs.coreutils}/bin/date +%Y%m%d-%H%M%S-%N)"
            exec ${pkgs.coreutils}/bin/mv -- "$target" "$target.hm-backup-$timestamp"
          '';
          home-manager.extraSpecialArgs = {
            inherit inputs userConfig;
          };
          home-manager.users.${username} = import ../../modules/home.nix;
        })
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
    import ./RyzenShine/host.nix { inherit mkHost config; };

  flake.homeConfigurations =
    (import ./Windows/host.nix { inherit mkHome; })
    // (import ./Linux/host.nix { inherit mkHome; });
}
