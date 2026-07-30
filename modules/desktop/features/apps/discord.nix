{ ... }:

{
  flake.modules.homeManager.apps-feature-discord = { pkgs, ... }: {
    home.packages = [ pkgs.discord ];

    # WebRTCPipeWireCapturer enables PipeWire-based screen capture for WebRTC
    # calls. The NixOS wrapper adds --ozone-platform=wayland but omits this
    # flag, so the portal picker never appears when trying to share a window.
    xdg.desktopEntries.discord = {
      name = "Discord";
      exec = "Discord --enable-features=WebRTCPipeWireCapturer";
      icon = "discord";
      settings.StartupWMClass = "discord";
    };
  };
}
