{ ... }:

{
  flake.modules.homeManager.workstation-feature-zed = {
    imports = [ ../home-manager/zed.nix ];
  };
}
