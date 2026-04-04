{ ... }:

{
  flake.modules.homeManager.terminal-feature-fzf = { pkgs, ... }: {
    home.packages = [ pkgs.fzf ];
  };
}
