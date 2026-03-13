{ lib, config, pkgs, ... }:

{
  options.modules.zed.enable = lib.mkEnableOption "zed";

  config = lib.mkIf config.modules.zed.enable {
    programs.zed-editor = {
      enable = true;
      userSettings = {
        autosave = "on_focus_change";
        vim_mode = true;
      };
    };

    xdg.desktopEntries."dev.zed.Zed" = {
      name = "Zed";
      genericName = "Text Editor";
      comment = "A high-performance, multiplayer code editor.";
      exec = "zeditor %U";
      icon = "zed";
      categories = [ "Utility" "TextEditor" "Development" "IDE" ];
      mimeType = [ "text/plain" "application/x-zerosize" "x-scheme-handler/zed" ];
      startupNotify = true;
    };
  };
}
