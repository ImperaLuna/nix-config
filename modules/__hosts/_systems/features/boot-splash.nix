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
      # Plymouth skips the firmware framebuffer (simpledrm) unless told to,
      # and waits for a real GPU driver instead. Nvidia only loads in stage 2,
      # so without this the splash never got a screen before SDDM started.
      "plymouth.use-simpledrm"
    ];

    # Shutdown text around the splash.
    # logind broadcasts "The system will reboot now!" to every terminal when
    # anything asks it to reboot (Nova's power menu calls it directly), and
    # the console shows it once the desktop closes. `systemctl --no-wall`
    # turns the broadcast off the same way, per call; this does it for all.
    systemd.services.logind-no-wall = {
      description = "Turn off logind's shutdown broadcast";
      after = [ "systemd-logind.service" ];
      bindsTo = [ "systemd-logind.service" ];
      wantedBy = [ "systemd-logind.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${config.systemd.package}/bin/busctl call org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager SetWallMessage sb \"\" false";
      };
    };
    # systemd arms the board's watchdog during reboot, to force one if the
    # shutdown hangs for 10 minutes. Handing it over prints "watchdog did not
    # stop!" over the screen. A hung shutdown now waits for the power button.
    systemd.settings.Manager.RebootWatchdogSec = "0";
  };
}
