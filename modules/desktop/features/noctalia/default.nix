{ ... }:

let
  theme = import ../../../_lib/theme.nix;
in
{
  flake.modules.homeManager.desktop-feature-noctalia = { pkgs, lib, ... }:
    let
      noctalia-shell = pkgs.noctalia-shell.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          substituteInPlace Modules/Bar/Widgets/Workspace.qml \
            --replace-fail "function onWorkspacesChanged()" "function onWorkspaceChanged()"
        '';
      });

      settingsJson = pkgs.writeText "noctalia-settings.json" (builtins.toJSON {
        settingsVersion = 59;

        general = {
          showChangelogOnStartup = false;
          telemetryEnabled = false;
          showScreenCorners = false;
          enableLockScreenMediaControls = false;
        };

        bar = {
          barType = "simple";
          position = "top";
          backgroundOpacity = 0.92;
          showCapsule = true;
          widgets = {
            left = [
              { id = "Launcher"; }
              { id = "Clock"; }
              { id = "ActiveWindow"; }
            ];
            center = [
              { id = "Workspace"; }
            ];
            right = [
              { id = "Tray"; }
              { id = "NotificationHistory"; }
              { id = "Volume"; }
              { id = "Brightness"; }
              { id = "ControlCenter"; }
            ];
          };
        };

        dock.enabled = false;

        colorSchemes = {
          darkMode = true;
          useWallpaperColors = false;
        };

        wallpaper = {
          enabled = true;
          overviewEnabled = true;
          useSolidColor = false;
          directory = "/home/imperaluna/Pictures/Wallpapers";
        };

        appLauncher = {
          terminalCommand = "ghostty -e";
          enableClipboardHistory = true;
          overviewLayer = false;
        };

        ui = {
          panelsAttachedToBar = true;
          panelBackgroundOpacity = 0.92;
        };

        notifications = {
          enabled = true;
          enableMediaToast = false;
          sounds.enabled = false;
        };

        location = {
          weatherEnabled = false;
          autoLocate = false;
        };
      } + "\n");
    in
    {
      home.packages = [
        noctalia-shell
      ];

      home.activation.seedNoctaliaSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        settings_file="$HOME/.config/noctalia/settings.json"
        mkdir -p "$HOME/.config/noctalia"

        if [ -L "$settings_file" ]; then
          case "$(readlink "$settings_file")" in
            /nix/store/*) rm "$settings_file" ;;
          esac
        fi

        if [ ! -e "$settings_file" ]; then
          cp ${settingsJson} "$settings_file"
          chmod u+w "$settings_file"
        fi
      '';

      xdg.configFile."noctalia/colors.json".text = builtins.toJSON {
      mPrimary = theme.primary;
      mOnPrimary = theme.bg;
      mSecondary = theme.secondary;
      mOnSecondary = theme.bg;
      mTertiary = theme.info;
      mOnTertiary = theme.bg;
      mError = theme.error;
      mOnError = theme.bg;
      mSurface = theme.bg;
      mOnSurface = theme.fg;
      mSurfaceVariant = theme.bgAlt;
      mOnSurfaceVariant = theme.fgDim;
      mOutline = theme.bgAlt;
      mShadow = "#000000";
      mHover = theme.primary;
      mOnHover = theme.bg;
    } + "\n";
  };
}
