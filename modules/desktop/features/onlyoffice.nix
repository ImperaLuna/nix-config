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

    # Keep a highest-priority desktop file in XDG_DATA_HOME for launchers that
    # merge duplicate app IDs from several profile directories differently.
    home.file.".local/share/applications/onlyoffice-desktopeditors.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Version=1.5
      Name=ONLYOFFICE
      GenericName=Document Editor
      Comment=Edit office documents
      Exec=${pkgs.onlyoffice-desktopeditors}/bin/onlyoffice-desktopeditors %U
      Icon=onlyoffice-desktopeditors
      Terminal=false
      Categories=Office;WordProcessor;Spreadsheet;Presentation;
    '';
  };
}
