{ ... }:

{
  flake.modules.homeManager.terminal-feature-home-manager = { pkgs, ... }: {
    home.packages = [ pkgs.home-manager ];
  };
}
