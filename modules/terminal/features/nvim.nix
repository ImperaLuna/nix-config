{ ... }:

{
  flake.modules.homeManager.terminal-feature-nvim = {
    imports = [ ../home-manager/nvim.nix ];
  };
}
