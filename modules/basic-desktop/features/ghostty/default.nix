{ ... }:

{
  flake.modules.homeManager.basic-desktop-feature-ghostty = { pkgs, ... }: {
    home.packages = [ pkgs.ghostty ];
    xdg.configFile."ghostty/config".source = ./assets/config;
  };
}
