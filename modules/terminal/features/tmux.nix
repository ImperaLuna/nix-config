{ ... }:

{
  flake.modules.homeManager.terminal-feature-tmux = {
    imports = [ ../home-manager/tmux.nix ];
  };
}
