{ inputs, ... }:

{
  flake.modules.homeManager.desktop-feature-qylock =
    { lib, pkgs, ... }:
    let
      # Keep in sync with the SDDM theme in modules/__hosts/RyzenShine/configuration.nix.
      theme = "pixel-dusk-city";
      qmlPath = lib.concatMapStringsSep ":" (p: "${p}/lib/qt-6/qml") [
        pkgs.qt6.qtdeclarative
        pkgs.qt6.qt5compat
        pkgs.qt6.qtmultimedia
      ];
      lockscreen = "${inputs.qylock}/quickshell-lockscreen";

      qylockLock = pkgs.writeShellApplication {
        name = "qylock-lock";
        runtimeInputs = [ pkgs.psmisc pkgs.quickshell ];
        text = ''
          export QML2_IMPORT_PATH="${lockscreen}/imports:${qmlPath}''${QML2_IMPORT_PATH:+:$QML2_IMPORT_PATH}"
          export QML_XHR_ALLOW_FILE_READ=1
          export XDG_SESSION_TYPE="''${XDG_SESSION_TYPE:-wayland}"
          export QS_THEME="${theme}"
          export QS_THEME_PATH="${inputs.qylock}/themes/${theme}"

          killall -9 hyprlock swaylock wlogout 2>/dev/null || true
          exec quickshell -p "${lockscreen}/lock_shell.qml"
        '';
      };
    in
    {
      # GStreamer plugins decode the theme's video background.
      home.packages = [ qylockLock ] ++ (with pkgs.gst_all_1; [
        gstreamer
        gst-libav
        gst-plugins-base
        gst-plugins-good
        gst-plugins-bad
        gst-plugins-ugly
      ]);
    };
}
