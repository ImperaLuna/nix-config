{ ... }:

{
  flake.modules.homeManager.terminal-feature-witr = {
    imports = [ ../home-manager/witr.nix ];
  };
}
