{ ... }:

{
  flake.modules.homeManager.terminal-feature-file = {
    imports = [ ../home-manager/file.nix ];
  };
}
