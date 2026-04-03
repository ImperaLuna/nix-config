{ ... }:

{
  flake.modules.homeManager.terminal-feature-direnv = {
    imports = [ ../home-manager/direnv.nix ];
  };
}
