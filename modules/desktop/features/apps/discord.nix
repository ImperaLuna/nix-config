{ ... }:

{
  flake.modules.homeManager.apps-feature-discord = { pkgs, ... }: {
    home.packages = [
      pkgs.discord
      pkgs.vesktop
    ];

    # WebRTCPipeWireCapturer enables PipeWire-based screen capture for WebRTC
    # calls. The NixOS wrapper adds --ozone-platform=wayland but omits this
    # flag, so the portal picker never appears when trying to share a window.
    xdg.desktopEntries.discord = {
      name = "Discord";
      exec = "Discord --enable-features=WebRTCPipeWireCapturer";
      icon = "discord";
      settings.StartupWMClass = "discord";
    };

    # Starts at login from ~/.config/autostart, so systemd runs it after
    # nova.service is ready and Discord finds Nova's tray.
    xdg.autostart = {
      enable = true;
      entries = [
        "${pkgs.makeDesktopItem {
          name = "discord";
          desktopName = "Discord";
          exec = "Discord --enable-features=WebRTCPipeWireCapturer --start-minimized";
          icon = "discord";
        }}/share/applications/discord.desktop"
      ];
    };
  };
}
