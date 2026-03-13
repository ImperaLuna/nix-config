{ lib, config, pkgs, ... }:

{
  options.modules.hyprland.enable = lib.mkEnableOption "hyprland";

  config = lib.mkIf config.modules.hyprland.enable {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };

    environment.systemPackages = with pkgs; [
      wl-clipboard
      grim
      slurp
      adwaita-icon-theme
    ];
  };
}
