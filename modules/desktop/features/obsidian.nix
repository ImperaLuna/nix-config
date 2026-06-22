{ ... }:

{
  flake.modules.homeManager.desktop-feature-obsidian = { pkgs, ... }: {
    home.packages = [ pkgs.obsidian ];

    xdg.desktopEntries.obsidian = {
      name = "Obsidian";
      exec = "obsidian";
      icon = "obsidian";
      settings.StartupWMClass = "obsidian";
    };
  };
}
