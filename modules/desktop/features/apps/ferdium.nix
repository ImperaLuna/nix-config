{ ... }:

{
  flake.modules.homeManager.apps-feature-ferdium = { pkgs, lib, ... }: {
    home.packages = [ pkgs.ferdium ];

    # Starts at login from ~/.config/autostart, so systemd runs it after
    # nova.service is ready and Ferdium finds Nova's tray. It starts
    # minimized through its own settings (startMinimized below).
    xdg.autostart = {
      enable = true;
      entries = [
        "${pkgs.makeDesktopItem {
          name = "ferdium";
          desktopName = "Ferdium";
          exec = "env ELECTRON_OZONE_PLATFORM_HINT=x11 ferdium";
          icon = "ferdium";
        }}/share/applications/ferdium.desktop"
      ];
    };

    home.activation.ferdiumTraySettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      settings_file="$HOME/.config/Ferdium/config/settings.json"
      mkdir -p "$HOME/.config/Ferdium/config"

      if [ -f "$settings_file" ]; then
        tmp_file="$(mktemp)"
        ${lib.getExe pkgs.jq} '
          .autoLaunchOnStart = false |
          .autoLaunchInBackground = false |
          .startMinimized = true |
          .minimizeToSystemTray = true |
          .closeToSystemTray = true |
          .enableSystemTray = true |
          .runInBackground = true |
          .hibernationStrategy = 2592000 |
          .wakeUpHibernationStrategy = 2592000 |
          .webRTCIPHandlingPolicy = "default_public_interface_only"
        ' "$settings_file" > "$tmp_file"
        mv "$tmp_file" "$settings_file"
      else
        cat > "$settings_file" <<'EOF'
{
  "autoLaunchOnStart": false,
  "autoLaunchInBackground": false,
  "startMinimized": true,
  "minimizeToSystemTray": true,
  "closeToSystemTray": true,
  "enableSystemTray": true,
  "runInBackground": true,
  "hibernationStrategy": 2592000,
  "wakeUpHibernationStrategy": 2592000,
  "webRTCIPHandlingPolicy": "default_public_interface_only"
}
EOF
      fi
    '';

    # WhatsApp Web calling needs cross-origin isolation, which disablewebsecurity
    # breaks. Upstream dropped the flag in recipe 3.5.8 (ferdium-recipes#739).
    home.activation.ferdiumWhatsappCalls = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      recipe_file="$HOME/.config/Ferdium/recipes/whatsapp/package.json"

      if [ -f "$recipe_file" ]; then
        tmp_file="$(mktemp)"
        ${lib.getExe pkgs.jq} 'del(.config.disablewebsecurity)' "$recipe_file" > "$tmp_file"
        mv "$tmp_file" "$recipe_file"
      fi
    '';
  };
}
