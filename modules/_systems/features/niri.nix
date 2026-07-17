{ pkgs, ... }:

{
  nixpkgs.overlays = [
    (_final: prev: {
      xdg-desktop-portal-wlr = prev.xdg-desktop-portal-wlr.overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          substituteInPlace $out/share/xdg-desktop-portal/portals/wlr.portal \
            --replace-fail 'UseIn=wlroots;sway;Wayfire;river;phosh;Hyprland;' \
                           'UseIn=wlroots;sway;Wayfire;river;phosh;Hyprland;niri;'
        '';
      });
    })
  ];

  programs.niri = {
    enable = true;
    useNautilus = false;
  };

  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
  xdg.portal.wlr = {
    enable = true;
    settings.screencast = {
      max_fps = 60;
      # Linear DMA-BUFs avoid static frames when NVIDIA imports the capture.
      force_mod_linear = true;
    };
  };
  xdg.portal.config.niri = {
    "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
    Screenshot = [ "gnome" ];
  };

  environment.systemPackages = with pkgs; [
    xwayland-satellite
  ];

  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
}
