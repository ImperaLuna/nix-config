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
    inputs.nixpkgs.lib.nixosSystem {
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
