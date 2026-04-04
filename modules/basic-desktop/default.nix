{ config, ... }:

{
  imports = import ../_lib/import-feature-tree.nix ./features;

  flake.modules.homeManager.basic-desktop = {
    imports = [
      config.flake.modules.homeManager.basic-desktop-feature-ghostty
      config.flake.modules.homeManager.basic-desktop-feature-bitwarden
      config.flake.modules.homeManager.basic-desktop-feature-obsidian
      config.flake.modules.homeManager.basic-desktop-feature-onlyoffice
      config.flake.modules.homeManager.basic-desktop-feature-zen
    ];
  };
}
