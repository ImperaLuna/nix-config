{ lib, config, ... }:

let
  cfg = config.modules.zed;
in

{
  options.modules.zed.manageSettings = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Whether this module manages Zed user settings and desktop entry overrides.";
  };

  config = {
    programs.zed-editor = {
      enable = true;
      userSettings = lib.mkIf cfg.manageSettings {
        base_keymap = "VSCode";
        theme = "Ayu Dark";
        autosave = "on_focus_change";
        vim_mode = true;
      };
    };

    xdg.desktopEntries."dev.zed.Zed" = lib.mkIf cfg.manageSettings {
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
