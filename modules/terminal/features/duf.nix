{ ... }:

{
  flake.modules.homeManager.terminal-feature-duf = {
    imports = [ ../home-manager/duf.nix ];
  };
}
