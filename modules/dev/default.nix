{ config, ... }:

{
  imports = import ../_lib/import-feature-tree.nix ./features;

  flake.modules.homeManager.dev = { pkgs, ... }: {
    imports = [
      config.flake.modules.homeManager.dev-feature-python
      config.flake.modules.homeManager.dev-feature-nova-worktree-cleanup
    ];

    home.packages = [ pkgs.nodejs_24 ];
  };
}
