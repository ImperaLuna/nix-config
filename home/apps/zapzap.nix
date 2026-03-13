{ lib, config, pkgs, ... }:

{
  options.modules.zapzap.enable = lib.mkEnableOption "zapzap";

  config = lib.mkIf config.modules.zapzap.enable {
    home.packages = [ pkgs.zapzap ];

    xdg.desktopEntries."com.rtosta.zapzap" = {
      name = "WhatsApp";
      comment = "WhatsApp Desktop for Linux";
      exec = "zapzap %u";
      icon = "com.rtosta.zapzap";
      terminal = false;
      categories = [ "Chat" "Network" "InstantMessaging" ];
      mimeType = [ "x-scheme-handler/whatsapp" ];
      settings = {
        StartupWMClass = "ZapZap";
        X-GNOME-UsesNotifications = "true";
        SingleMainWindow = "true";
      };
    };
  };
}
