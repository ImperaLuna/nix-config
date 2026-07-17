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

  # The GNOME portal cannot negotiate Discord's video format on NVIDIA.
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
  xdg.portal.wlr.enable = true;
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
