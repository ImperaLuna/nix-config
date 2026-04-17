{ ... }:

{
  flake.modules.homeManager.desktop-feature-onlyoffice = { pkgs, ... }: {
    home.packages = [ pkgs.onlyoffice-desktopeditors ];
  };
}
