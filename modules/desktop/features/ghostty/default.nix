{ ... }:

{
  flake.modules.homeManager.desktop-feature-ghostty = { pkgs, ... }: {
    home.packages = [ pkgs.ghostty ];
    xdg.configFile."ghostty/config".source = ./assets/config;
    xdg.configFile."ghostty/shaders/cursor_blaze.glsl".source = ./assets/shaders/cursor_blaze.glsl;
    xdg.configFile."ghostty/shaders/sparks-from-fire.glsl".source = ./assets/shaders/sparks-from-fire.glsl;
  };
}
