{ pkgs, ... }:

{
  home.packages = with pkgs; [
    yazi
    ffmpeg
    p7zip
    poppler
    jq
    resvg
    imagemagick
  ];

  xdg.configFile."yazi/yazi.toml".source =
    ../../../home/terminal/modules/yazi/assets/yazi.toml;
  xdg.configFile."yazi/keymap.toml".source =
    ../../../home/terminal/modules/yazi/assets/keymap.toml;
  xdg.configFile."yazi/theme.toml".source =
    ../../../home/terminal/modules/yazi/assets/theme.toml;
  xdg.configFile."yazi/flavors/catppuccin-mocha-mauve.yazi/flavor.toml".source =
    ../../../home/terminal/modules/yazi/assets/flavors/catppuccin-mocha-mauve.yazi/flavor.toml;
}
