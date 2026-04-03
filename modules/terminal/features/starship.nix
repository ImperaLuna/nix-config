{ ... }:

{
  flake.modules.homeManager.terminal-feature-starship = {
    imports = [ ../home-manager/starship.nix ];
  };
}
