{ config, ... }:

{
  imports = import ../_lib/import-feature-tree.nix ./features;

  flake.modules.homeManager.apps = {
    imports = [
      config.flake.modules.homeManager.apps-feature-discord
      config.flake.modules.homeManager.apps-feature-ferdium
    ];
  };
}
