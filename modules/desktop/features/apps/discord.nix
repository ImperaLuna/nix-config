{ ... }:

{
  flake.modules.homeManager.apps-feature-discord = { pkgs, ... }: {
    home.packages = [ pkgs.vesktop ];

    xdg.dataFile."icons/hicolor/256x256/apps/discord.png".source = ./assets/discord.png;

    xdg.desktopEntries.vesktop = {
      name = "Discord";
      genericName = "Internet Messenger";
      exec = "vesktop %U";
      icon = "discord";
      categories = [ "Network" "InstantMessaging" "Chat" ];
      mimeType = [ "x-scheme-handler/discord" ];
      settings.StartupWMClass = "Vesktop";
    };

    # Starts at login from ~/.config/autostart, so systemd runs it after
    # nova.service is ready and Discord finds Nova's tray.
    xdg.autostart = {
      enable = true;
      entries = [
        "${pkgs.makeDesktopItem {
          name = "vesktop";
          desktopName = "Discord";
          exec = "vesktop --start-minimized";
          icon = "discord";
        }}/share/applications/vesktop.desktop"
      ];
    };
  };
}
