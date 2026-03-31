{ lib, config, pkgs, ... }:

{
  options.modules.tutanota.enable = lib.mkEnableOption "tutanota";

  config = lib.mkIf config.modules.tutanota.enable {
    home.packages = [ pkgs.tutanota-desktop ];

    xdg.desktopEntries."tutanota-desktop" = {
      name = "Tuta Mail";
      comment = "The desktop client for Tutanota, the secure e-mail service.";
      exec = "${pkgs.coreutils}/bin/env NODE_OPTIONS=--dns-result-order=ipv4first ${pkgs.tutanota-desktop}/bin/tutanota-desktop --no-sandbox %U";
      icon = "tutanota-desktop";
      terminal = false;
      categories = [ "Network" ];
      mimeType = [ "x-scheme-handler/mailto" ];
      settings = {
        StartupWMClass = "Tuta Mail";
      };
    };
  };
}
