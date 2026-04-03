{ pkgs, ... }:

{
  home.packages = [ pkgs.eza ];

  xdg.configFile."eza/theme.yml".source =
    ../../../home/terminal/modules/eza/assets/theme.yml;
}
