{ inputs, config, ... }:

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
in
{
  flake.nixosConfigurations =
    (import ./RyzenShine/host.nix { inherit mkHost config; })
    // (import ./DuskNova/host.nix { inherit mkHost config; });
}
