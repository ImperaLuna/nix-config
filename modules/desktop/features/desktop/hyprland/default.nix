{ ... }:

{
  flake.modules.homeManager.desktop-feature-hyprland = {
    xdg.configFile."hypr".source = ./assets/hypr;
  };
}
