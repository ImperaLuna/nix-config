{ ... }:

{
  flake.modules.homeManager.terminal-feature-fish = {
    imports = [ ../home-manager/fish.nix ];
  };
}
