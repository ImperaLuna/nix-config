{ ... }:

{
  flake.modules.homeManager.workstation-feature-ghostty = {
    imports = [ ../home-manager/ghostty.nix ];
  };
}
