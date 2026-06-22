{ ... }:

{
  flake.modules.homeManager.terminal-feature-gh = { pkgs, ... }: {
    home.packages = [ pkgs.gh ];
  };
}
