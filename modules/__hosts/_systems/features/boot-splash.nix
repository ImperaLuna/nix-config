{ config, lib, pkgs, ... }:

let
  cfg = config.boot.splash;
in
{
  options.boot.splash = {
    enable = lib.mkEnableOption "a Plymouth splash in place of the boot log";

    theme = lib.mkOption {
      type = lib.types.str;
      default = "loader";
      description = "Theme from the adi1090x pack. Previews: https://github.com/adi1090x/plymouth-themes";
    };
  };

  config = lib.mkIf cfg.enable {
    boot.plymouth = {
      enable = true;
      inherit (cfg) theme;
      # The pack holds 80 themes (about 300 MB); install only the one in use.
      themePackages = [
        (pkgs.adi1090x-plymouth-themes.override { selected_themes = [ cfg.theme ]; })
      ];
    };

    # Hide the routine log. Errors still reach the console, and Esc during
    # boot swaps the splash for the log.
    boot.consoleLogLevel = 3;
    boot.kernelParams = [
      "quiet"
      "splash"
      "udev.log_level=3"
      "rd.udev.log_level=3"
      "rd.systemd.show_status=auto"
      "systemd.show_status=auto"
    ];
  };
}
