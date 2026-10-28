{ ... }:

{
  flake.modules.homeManager.desktop-feature-onlyoffice = { pkgs, ... }: {
    home.packages = [ pkgs.onlyoffice-desktopeditors ];

    # Use the package path directly so application launchers do not depend on
    # shell PATH or UWSM desktop-entry handling.
    xdg.desktopEntries.onlyoffice-desktopeditors = {
      name = "ONLYOFFICE";
      genericName = "Document Editor";
      comment = "Edit office documents";
      exec = "${pkgs.onlyoffice-desktopeditors}/bin/onlyoffice-desktopeditors %U";
      icon = "onlyoffice-desktopeditors";
      terminal = false;
      categories = [ "Office" "WordProcessor" "Spreadsheet" "Presentation" ];
    };
  };
}
