{ config, ... }:

{
  imports = import ../_lib/import-feature-tree.nix ./features;

  flake.modules.homeManager.desktop = {
    imports = [
      config.flake.modules.homeManager.desktop-feature-hyprland
      config.flake.modules.homeManager.desktop-feature-dms
    ];
  };
}
