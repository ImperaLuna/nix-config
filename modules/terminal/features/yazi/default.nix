{ ... }:

{
  flake.modules.homeManager.terminal-feature-yazi = { pkgs, ... }:
    let
      yaziLauncher = pkgs.writeShellScriptBin "yazi-launch" ''
        exec ${pkgs.ghostty}/bin/ghostty -e ${pkgs.yazi}/bin/yazi "$@"
      '';
    in
    {
      home.packages = with pkgs; [
        yaziLauncher
        yazi
        ffmpeg
        p7zip
        poppler
        jq
        resvg
        imagemagick
        loupe
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
        exec = "yazi-launch %F";
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

    };
}
