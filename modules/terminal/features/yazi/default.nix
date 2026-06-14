{ ... }:

{
  flake.modules.homeManager.terminal-feature-yazi = { pkgs, ... }:
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

      xdg.configFile."yazi/yazi.toml".source = ./assets/yazi.toml;
      xdg.configFile."yazi/keymap.toml".source = ./assets/keymap.toml;
      xdg.configFile."yazi/theme.toml".source = ./assets/theme.toml;
      xdg.configFile."yazi/flavors/catppuccin-mocha-mauve.yazi/flavor.toml".source =
        ./assets/flavors/catppuccin-mocha-mauve.yazi/flavor.toml;

      xdg.desktopEntries.yazi = {
        name = "Yazi File Manager";
        genericName = "Terminal File Manager";
        comment = "Blazing fast terminal file manager written in Rust, based on async I/O";
        exec = "ghostty -e yazi %F";
        icon = "yazi";
        categories = [
          "System"
          "FileManager"
          "FileTools"
          "ConsoleOnly"
        ];
        mimeType = [ "inode/directory" ];
        startupNotify = true;
        settings.Keywords = "File;Manager;Explorer;Browser;Launcher;";
      };

      home.file.".local/share/applications/yazi.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=Yazi File Manager
        GenericName=Terminal File Manager
        Comment=Blazing fast terminal file manager written in Rust, based on async I/O
        Exec=ghostty -e yazi %F
        Icon=yazi
        Categories=System;FileManager;FileTools;ConsoleOnly;
        Keywords=File;Manager;Explorer;Browser;Launcher;
        MimeType=inode/directory;
        StartupNotify=true
      '';
    };
}
