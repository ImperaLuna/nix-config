{ ... }:

{
  flake.modules.homeManager.terminal-feature-eza = {
    imports = [ ../home-manager/eza.nix ];
  };
}
