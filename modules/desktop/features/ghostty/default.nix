{ ... }:

let
  theme = import ../../../_lib/theme.nix;
  hex = color: builtins.substring 1 6 color;
in
{
  flake.modules.homeManager.desktop-feature-ghostty = { pkgs, ... }: {
    home.packages = [ pkgs.ghostty ];
    xdg.configFile."ghostty/config".text = (builtins.readFile ./assets/config) + ''

      selection-background = ${hex theme.primary}
      selection-foreground = ${hex theme.bg}
    '';
    xdg.configFile."ghostty/shaders/cursor_blaze.glsl".source = ./assets/shaders/cursor_blaze.glsl;
    xdg.configFile."ghostty/shaders/sparks-from-fire.glsl".source = ./assets/shaders/sparks-from-fire.glsl;
  };
}
