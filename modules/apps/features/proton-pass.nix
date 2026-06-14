{ ... }:

{
  flake.modules.homeManager.apps-feature-proton-pass = { pkgs, ... }: {
    home.packages = [ pkgs.proton-pass ];
  };
}
