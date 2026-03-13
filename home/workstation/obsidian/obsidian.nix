{ lib, config, pkgs, ... }:

{
  options.modules.obsidian.enable = lib.mkEnableOption "obsidian";

  config = lib.mkIf config.modules.obsidian.enable {
    home.packages = [ pkgs.obsidian ];

    xdg.desktopEntries.obsidian = {
      name = "Obsidian";
      comment = "Knowledge base";
      exec = "obsidian %u";
      icon = "obsidian";
      categories = [ "Office" ];
      mimeType = [ "x-scheme-handler/obsidian" ];
    };
  };
}
