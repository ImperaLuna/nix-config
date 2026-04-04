{ config, ... }:

{
  imports = import ../_lib/import-feature-tree.nix ./features;

  flake.modules.homeManager.gaming = {
    imports = [
      config.flake.modules.homeManager.gaming-feature-albion
      config.flake.modules.homeManager.gaming-feature-albion-autorun
    ];
  };
}
