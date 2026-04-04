{ inputs, self, ... }:

{
  flake.nixosModules.home-stack = { ... }: {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.sharedModules = [
      self.modules.homeManager.terminal-role-default
      self.modules.homeManager.workstation-role-default
      self.modules.homeManager.experimental
    ];
  };
}
