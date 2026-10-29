{ ... }:

{
  flake.modules.homeManager.apps-feature-lmstudio = { pkgs, ... }: {
    home.packages = [ pkgs.lmstudio ];
  };
}
