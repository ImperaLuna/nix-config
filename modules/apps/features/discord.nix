{ ... }:

{
  flake.modules.homeManager.apps-feature-discord = { pkgs, ... }: {
    home.packages = [ pkgs.discord ];
  };
}
