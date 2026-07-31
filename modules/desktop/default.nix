{ config, ... }:

{
  imports = import ../_lib/import-feature-tree.nix ./features;

  flake.modules.homeManager.desktop = {
    imports = [
      config.flake.modules.homeManager.apps-feature-discord
      config.flake.modules.homeManager.apps-feature-ferdium
      config.flake.modules.homeManager.apps-feature-excalidraw
      config.flake.modules.homeManager.apps-feature-proton-pass
      config.flake.modules.homeManager.apps-feature-spotify
      config.flake.modules.homeManager.apps-feature-stremio
      config.flake.modules.homeManager.desktop-feature-gtk
      config.flake.modules.homeManager.desktop-feature-cursor
      config.flake.modules.homeManager.desktop-feature-hyprland
      config.flake.modules.homeManager.desktop-feature-niri
      config.flake.modules.homeManager.desktop-feature-nova
      config.flake.modules.homeManager.desktop-feature-qylock
      config.flake.modules.homeManager.desktop-feature-ghostty
      config.flake.modules.homeManager.desktop-feature-obsidian
      config.flake.modules.homeManager.desktop-feature-onlyoffice
      config.flake.modules.homeManager.desktop-feature-zen
      config.flake.modules.homeManager.desktop-feature-voxtype
    ];
  };
}
