{ ... }:

{
  flake.modules.homeManager.terminal-feature-btop = {
    imports = [ ../home-manager/btop.nix ];
  };
}
