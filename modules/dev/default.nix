{ config, ... }:

{
  imports = import ../_lib/import-feature-tree.nix ./features;

  flake.modules.homeManager.dev = {
    imports = [
      config.flake.modules.homeManager.dev-feature-opencode
      config.flake.modules.homeManager.dev-feature-python
      config.flake.modules.homeManager.dev-feature-zed
    ];
  };
}
