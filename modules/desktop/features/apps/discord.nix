{ ... }:

{
  flake.modules.homeManager.apps-feature-discord = { pkgs, ... }: {
    # Notifications carry the icon name "vesktop", so the package's own
    # vesktop.png icons are swapped for the Discord one.
    home.packages = [
      (pkgs.symlinkJoin {
        name = "vesktop-discord-icon";
        paths = [ pkgs.vesktop ];
        nativeBuildInputs = [ pkgs.imagemagick ];
        postBuild = ''
          for icon in $out/share/icons/hicolor/*/apps/vesktop.png; do
            size=$(basename $(dirname $(dirname $icon)))
            rm $icon
            magick ${./assets/discord.png} -resize $size $icon
          done
        '';
      })
    ];

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
