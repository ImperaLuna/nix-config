{ lib, config, pkgs, ... }:

{
  options.modules.ghostty.enable = lib.mkEnableOption "ghostty";

  config = lib.mkIf config.modules.ghostty.enable {
    home.packages = [ pkgs.ghostty ];
    xdg.configFile."ghostty/config".source = ./assets/config;
  };
}
