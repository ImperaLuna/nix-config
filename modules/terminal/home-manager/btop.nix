{ pkgs, config, ... }:

{
  home.packages = [ pkgs.btop ];

  xdg.configFile."btop/btop.conf".text =
    builtins.replaceStrings
      [ "/home/imperaluna" ]
      [ config.home.homeDirectory ]
      (builtins.readFile ../../../home/terminal/modules/btop/assets/btop.conf);
  xdg.configFile."btop/themes/catppuccin_mocha.theme".source =
    ../../../home/terminal/modules/btop/assets/themes/catppuccin_mocha.theme;
}
