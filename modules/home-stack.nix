{ inputs, self, ... }:

{
  flake.nixosModules.home-desktop = { ... }: {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.sharedModules = [
      self.modules.homeManager.terminal-desktop
      self.modules.homeManager.dev
      self.modules.homeManager.apps
      self.modules.homeManager.gaming
      self.modules.homeManager.desktop
      self.modules.homeManager.workstation
      self.modules.homeManager.experimental
    ];
  };

  flake.nixosModules.home-lab = { ... }: {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.sharedModules = [
      self.modules.homeManager.terminal
      self.modules.homeManager.dev
    ];
  };
}
