{ ... }:

{
  flake.modules.homeManager.apps-feature-spotify = { pkgs, ... }: {
    home.packages = [ pkgs.spotify ];
  };
}
