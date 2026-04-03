{ ... }:

{
  flake.modules.homeManager.terminal-feature-ripgrep = {
    imports = [ ../home-manager/ripgrep.nix ];
  };
}
