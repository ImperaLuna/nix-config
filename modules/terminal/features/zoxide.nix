{ ... }:

{
  flake.modules.homeManager.terminal-feature-zoxide = {
    imports = [ ../home-manager/zoxide.nix ];
  };
}
