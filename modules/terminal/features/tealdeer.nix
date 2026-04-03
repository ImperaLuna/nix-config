{ ... }:

{
  flake.modules.homeManager.terminal-feature-tealdeer = {
    imports = [ ../home-manager/tealdeer.nix ];
  };
}
