{ ... }:

{
  flake.modules.homeManager.terminal-feature-gh-dash = { pkgs, ... }: {
    home.packages = [ pkgs.gh-dash ];
  };
}
