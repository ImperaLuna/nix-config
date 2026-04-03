{ pkgs, ... }:

{
  home.packages = [ pkgs.lazygit ];

  xdg.configFile."lazygit/config.yml".source =
    ../../../home/terminal/modules/lazygit/assets/config.yml;
}
