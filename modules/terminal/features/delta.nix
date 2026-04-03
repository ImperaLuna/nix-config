{ ... }:

{
  flake.modules.homeManager.terminal-feature-delta = {
    imports = [ ../home-manager/delta.nix ];
  };
}
