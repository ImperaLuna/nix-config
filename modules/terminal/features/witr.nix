{ ... }:

{
  flake.modules.homeManager.terminal-feature-witr = { pkgs, ... }: {
    home.packages = [ pkgs.witr ];
  };
}
