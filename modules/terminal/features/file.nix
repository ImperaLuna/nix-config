{ ... }:

{
  flake.modules.homeManager.terminal-feature-file = { pkgs, ... }: {
    home.packages = [ pkgs.file ];
  };
}
