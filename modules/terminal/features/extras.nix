{ ... }:

{
  flake.modules.homeManager.terminal-feature-extras = {
    imports = [ ../home-manager/extras.nix ];
  };
}
