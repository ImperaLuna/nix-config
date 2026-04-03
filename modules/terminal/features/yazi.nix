{ ... }:

{
  flake.modules.homeManager.terminal-feature-yazi = {
    imports = [ ../home-manager/yazi.nix ];
  };
}
