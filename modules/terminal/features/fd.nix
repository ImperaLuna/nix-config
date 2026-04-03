{ ... }:

{
  flake.modules.homeManager.terminal-feature-fd = {
    imports = [ ../home-manager/fd.nix ];
  };
}
