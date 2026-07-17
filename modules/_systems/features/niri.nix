{ pkgs, ... }:

{
  programs.niri = {
    enable = true;
    useNautilus = false;
  };

  xdg.portal.config.niri = {
    "org.freedesktop.impl.portal.ScreenCast" = "gnome";
    Screenshot = [ "gnome" ];
  };

  environment.systemPackages = with pkgs; [
    xwayland-satellite
  ];

  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
}
