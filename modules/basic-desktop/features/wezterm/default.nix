{ ... }:

{
  flake.modules.homeManager.basic-desktop-feature-wezterm = { pkgs, ... }: {
    home.packages = [ pkgs.wezterm ];
    xdg.configFile."wezterm/wezterm.lua".source = ./assets/wezterm.lua;
  };
}
