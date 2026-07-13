{ ... }:

{
  flake.modules.homeManager.terminal-feature-desktop-integrations =
    { config, pkgs, ... }:
    let
      btopLauncher = pkgs.writeShellScriptBin "btop-launch" ''
        exec ${pkgs.ghostty}/bin/ghostty -e ${pkgs.btop}/bin/btop "$@"
      '';
      nvimLauncher = pkgs.writeShellScriptBin "nvim-launch" ''
        exec ${pkgs.ghostty}/bin/ghostty -e ${config.programs.nixvim.build.package}/bin/nvim "$@"
      '';
      yaziLauncher = pkgs.writeShellScriptBin "yazi-launch" ''
        exec ${pkgs.ghostty}/bin/ghostty -e ${pkgs.yazi}/bin/yazi "$@"
      '';
    in
    {
      home.packages = [
        btopLauncher
        nvimLauncher
        yaziLauncher
        pkgs.wl-clipboard
        pkgs.ffmpeg
        pkgs.mpv
        pkgs.poppler
        pkgs.resvg
        pkgs.imagemagick
        pkgs.loupe
      ];

      xdg.desktopEntries = {
        btop = {
          name = "Btop";
          genericName = "System Monitor";
          exec = "btop-launch";
          icon = "btop";
          categories = [ "System" "Monitor" ];
          startupNotify = true;
        };

        nvim = {
          name = "Neovim";
          genericName = "Text Editor";
          exec = "nvim-launch %F";
          icon = "nvim";
          categories = [ "Utility" "TextEditor" "Development" ];
          mimeType = [
            "text/plain"
            "text/markdown"
            "text/x-nix"
            "application/json"
            "application/x-shellscript"
          ];
          startupNotify = true;
        };

        yazi = {
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
    };
}
