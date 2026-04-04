{ ... }:

{
  flake.modules.homeManager.basic-desktop-feature-onlyoffice = { pkgs, ... }: {
    home.packages = [ pkgs.onlyoffice-desktopeditors ];
  };
}
