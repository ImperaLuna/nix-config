{ ... }:

{
  flake.modules.homeManager.terminal-feature-stow = { pkgs, ... }: {
    home.packages = [ pkgs.stow ];
  };
}
