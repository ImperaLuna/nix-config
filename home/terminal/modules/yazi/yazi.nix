{ pkgs, lib, config, ... }:

{
  options.modules.yazi.enable = lib.mkEnableOption "yazi";

  config = lib.mkIf config.modules.yazi.enable {
    home.packages = with pkgs; [
      yazi
      ffmpeg
      p7zip
      poppler
      jq
      resvg
      imagemagick
    ];

    xdg.configFile."yazi/yazi.toml".source = ./assets/yazi.toml;
    xdg.configFile."yazi/keymap.toml".source = ./assets/keymap.toml;
    xdg.configFile."yazi/theme.toml".source = ./assets/theme.toml;
    xdg.configFile."yazi/flavors/catppuccin-mocha-mauve.yazi/flavor.toml".source =
      ./assets/flavors/catppuccin-mocha-mauve.yazi/flavor.toml;
  };
}
