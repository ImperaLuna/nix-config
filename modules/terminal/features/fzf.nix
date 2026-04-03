{ ... }:

{
  flake.modules.homeManager.terminal-feature-fzf = {
    imports = [ ../home-manager/fzf.nix ];
  };
}
