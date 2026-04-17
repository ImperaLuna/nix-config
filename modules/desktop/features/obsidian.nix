{ ... }:

{
  flake.modules.homeManager.desktop-feature-obsidian = { pkgs, ... }: {
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
