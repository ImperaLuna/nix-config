{ pkgs, ... }:

{
  home.packages = [ pkgs.ghostty ];
  xdg.configFile."ghostty/config".source =
    ../../../home/workstation/ghostty/assets/config;
}
