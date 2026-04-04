{ pkgs, ... }:

{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  xdg.portal.enable = true;

  environment.systemPackages = with pkgs; [
    wl-clipboard
    grim
    slurp
    adwaita-icon-theme
  ];
}
