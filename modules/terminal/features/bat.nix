{ ... }:

{
  flake.modules.homeManager.terminal-feature-bat = {
    imports = [ ../home-manager/bat.nix ];
  };
}
