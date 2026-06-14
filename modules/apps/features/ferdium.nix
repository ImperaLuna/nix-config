{ ... }:

{
  flake.modules.homeManager.apps-feature-ferdium = { pkgs, lib, ... }: {
    home.packages = [ pkgs.ferdium ];

    home.activation.ferdiumTraySettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      settings_file="$HOME/.config/Ferdium/config/settings.json"
      mkdir -p "$HOME/.config/Ferdium/config"

      if [ -f "$settings_file" ]; then
        tmp_file="$(mktemp)"
        ${lib.getExe pkgs.jq} '
          .autoLaunchOnStart = false |
          .autoLaunchInBackground = false |
          .startMinimized = false |
          .minimizeToSystemTray = true |
          .closeToSystemTray = true |
          .enableSystemTray = true |
          .runInBackground = true |
          .hibernationStrategy = 2592000 |
          .wakeUpHibernationStrategy = 2592000
        ' "$settings_file" > "$tmp_file"
        mv "$tmp_file" "$settings_file"
      else
        cat > "$settings_file" <<'EOF'
{
  "autoLaunchOnStart": false,
  "autoLaunchInBackground": false,
  "startMinimized": false,
  "minimizeToSystemTray": true,
  "closeToSystemTray": true,
  "enableSystemTray": true,
  "runInBackground": true,
  "hibernationStrategy": 2592000,
  "wakeUpHibernationStrategy": 2592000
}
EOF
      fi
    '';
  };
}
