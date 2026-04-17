{ config, ... }:

{
  imports = import ../_lib/import-feature-tree.nix ./features;

  flake.modules.homeManager.desktop = {
    imports = [
      config.flake.modules.homeManager.desktop-feature-hyprland
      config.flake.modules.homeManager.desktop-feature-dms
      config.flake.modules.homeManager.desktop-feature-qylock
      config.flake.modules.homeManager.desktop-feature-ghostty
      config.flake.modules.homeManager.desktop-feature-bitwarden
      config.flake.modules.homeManager.desktop-feature-obsidian
      config.flake.modules.homeManager.desktop-feature-onlyoffice
      config.flake.modules.homeManager.desktop-feature-zen
    ];
  };
}
