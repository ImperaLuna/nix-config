{ inputs, self, ... }:

{
  flake.nixosModules.home-stack = { ... }: {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.sharedModules = [
      self.modules.homeManager.terminal
      self.modules.homeManager.apps
      self.modules.homeManager.gaming
      self.modules.homeManager.basic-desktop
      self.modules.homeManager.desktop
      self.modules.homeManager.workstation
      self.modules.homeManager.python
      self.modules.homeManager.experimental
    ];
  };
}
