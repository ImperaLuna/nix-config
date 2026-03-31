{ lib, config, pkgs, ... }:

{
  options.modules.ferdium.enable = lib.mkEnableOption "ferdium";

  config = lib.mkIf config.modules.ferdium.enable {
    home.packages = [ pkgs.ferdium ];

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
          .runInBackground = true
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
  "runInBackground": true
}
EOF
      fi
    '';
  };
}
