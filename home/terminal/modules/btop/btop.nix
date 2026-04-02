{ pkgs, lib, config, ... }:

{
  options.modules.btop.enable = lib.mkEnableOption "btop";

  config = lib.mkIf config.modules.btop.enable {
    home.packages = [ pkgs.btop ];

    xdg.configFile."btop/btop.conf".text =
      builtins.replaceStrings
        [ "/home/imperaluna" ]
        [ config.home.homeDirectory ]
        (builtins.readFile ./assets/btop.conf);
    xdg.configFile."btop/themes/catppuccin_mocha.theme".source =
      ./assets/themes/catppuccin_mocha.theme;
  };
}
