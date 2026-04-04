{ ... }:

{
  flake.modules.homeManager.terminal-feature-ripgrep = { pkgs, ... }: {
    home.packages = [ pkgs.ripgrep ];
  };
}
