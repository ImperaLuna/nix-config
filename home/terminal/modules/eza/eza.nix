{ pkgs, lib, config, ... }:

{
  options.modules.eza.enable = lib.mkEnableOption "eza";

  config = lib.mkIf config.modules.eza.enable {
    home.packages = [ pkgs.eza ];

    xdg.configFile."eza/theme.yml".source = ./assets/theme.yml;
  };
}
