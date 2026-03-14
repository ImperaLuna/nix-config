{ lib, config, pkgs, ... }:

{
  options.modules.hyprland.enable = lib.mkEnableOption "hyprland";

  config = lib.mkIf config.modules.hyprland.enable {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };

    # Keep portals explicit for readability.
    # Hyprland's NixOS module provides xdg-desktop-portal-hyprland and
    # xdg-desktop-portal-gtk automatically.
    xdg.portal.enable = true;

    environment.systemPackages = with pkgs; [
      wl-clipboard
      grim
      slurp
      adwaita-icon-theme
    ];
  };
}
