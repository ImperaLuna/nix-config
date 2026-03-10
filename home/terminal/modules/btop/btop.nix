{ pkgs, lib, config, ... }:

{
  options.modules.btop.enable = lib.mkEnableOption "btop";

  config = lib.mkIf config.modules.btop.enable {
    home.packages = [ pkgs.btop ];

    xdg.configFile."btop/btop.conf".source = ./assets/btop.conf;
    xdg.configFile."btop/themes/catppuccin_mocha.theme".source =
      ./assets/themes/catppuccin_mocha.theme;
  };
}
