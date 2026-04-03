{ ... }:

{
  flake.modules.homeManager.terminal-feature-lazygit = {
    imports = [ ../home-manager/lazygit.nix ];
  };
}
