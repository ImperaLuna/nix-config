{ inputs, ... }:

{
  flake.modules.homeManager.desktop-feature-qylock =
    { config, lib, pkgs, ... }:
    let
      disabledThemes = [
        "minecraft"
        "terraria"
        "windows_7"
      ];
      disabledThemesPattern = lib.concatStringsSep "|" disabledThemes;
      qylockRuntimeDir = "${config.home.homeDirectory}/.local/share/qylock";
      qylockLock = pkgs.writeShellScriptBin "qylock-lock" ''
        set -eu

        qml2_import_path="''${QML2_IMPORT_PATH-}"
        qt_qml_paths="${pkgs.qt6.qtdeclarative}/lib/qt-6/qml:${pkgs.qt6.qt5compat}/lib/qt-6/qml:${pkgs.qt6.qtmultimedia}/lib/qt-6/qml"
        export QML2_IMPORT_PATH="${qylockRuntimeDir}/quickshell-lockscreen/imports:$qt_qml_paths''${qml2_import_path:+:}$qml2_import_path"
        export QML_XHR_ALLOW_FILE_READ=1

        if [ -n "''${XDG_SESSION_TYPE:-}" ]; then
          export XDG_SESSION_TYPE
        else
          export XDG_SESSION_TYPE="$(${pkgs.systemd}/bin/loginctl show-session "$(${pkgs.systemd}/bin/loginctl | ${pkgs.gnugrep}/bin/grep "$(whoami)" | ${pkgs.gawk}/bin/awk '{print $1}' | head -n1)" -p Type --value 2>/dev/null || printf wayland)"
        fi

        if [ "$#" -gt 0 ]; then
          export QS_THEME="$1"
        elif [ -f "${config.xdg.configHome}/qylock/theme" ]; then
          export QS_THEME="$(${pkgs.coreutils}/bin/cat "${config.xdg.configHome}/qylock/theme")"
        else
          export QS_THEME="nier-automata"
        fi

        if [ "$QS_THEME" = "random" ]; then
          random_theme_path="$(
            ${pkgs.findutils}/bin/find -L "${qylockRuntimeDir}/themes" -mindepth 1 -maxdepth 1 -type d \
              -exec test -f '{}/metadata.desktop' ';' -print |
              ${pkgs.gnugrep}/bin/grep -Ev '/(${disabledThemesPattern})$' |
              ${pkgs.coreutils}/bin/shuf -n 1
          )"
          export QS_THEME="''${random_theme_path##*/}"
        fi

        export QS_THEME_PATH="${qylockRuntimeDir}/themes/$QS_THEME"

        ${pkgs.procps}/bin/killall -9 hyprlock swaylock wlogout 2>/dev/null || true
        exec ${lib.getExe pkgs.quickshell} -p "${qylockRuntimeDir}/quickshell-lockscreen/lock_shell.qml"
      '';
    in
    {
      home.packages = with pkgs; [
        quickshell
        qylockLock
        procps
        qt6.qt5compat
        qt6.qtdeclarative
        qt6.qtmultimedia
        gst_all_1.gstreamer
        gst_all_1.gst-libav
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-good
        gst_all_1.gst-plugins-bad
        gst_all_1.gst-plugins-ugly
      ];

      home.file.".local/share/qylock/quickshell-lockscreen".source =
        "${inputs.qylock}/quickshell-lockscreen";
      home.file.".local/share/qylock/themes".source =
        "${inputs.qylock}/themes";

      xdg.configFile."qylock/theme".text = "random\n";
    };
}
