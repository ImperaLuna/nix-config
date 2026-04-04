{ config, ... }:

{
  imports = import ../_lib/import-feature-tree.nix ./features;

  flake.modules.homeManager.workstation = {
    imports = [
      config.flake.modules.homeManager.workstation-feature-headlamp
      config.flake.modules.homeManager.workstation-feature-zed
      config.flake.modules.homeManager.workstation-feature-opencode-desktop
    ];
  };
}
