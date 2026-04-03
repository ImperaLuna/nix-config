{ ... }:

{
  flake.modules.homeManager.terminal-feature-dust = {
    imports = [ ../home-manager/dust.nix ];
  };
}
