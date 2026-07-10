{ ... }:

{
  flake.modules.homeManager.apps-feature-stremio = { pkgs, ... }:
  let
    trackerList = ''module.exports = [ "http://tracker.opentrackr.org:1337/announce", "http://tracker.tritan.gg:8080/announce", "http://tracker.renfei.net:8080/announce", "http://tracker.qu.ax:6969/announce", "http://tracker.dhitechnical.com:6969/announce", "http://t.overflow.biz:6969/announce", "http://bittorrent-tracker.e-n-c-r-y-p-t.net:1337/announce", "http://004430.xyz:80/announce", "http://tracker2.dler.org:80/announce", "http://tracker.dler.org:6969/announce", "http://tracker.dler.com:6969/announce", "http://tracker.bt4g.com:2095/announce", "http://tracker.waaa.moe:6969/announce", "http://tracker.skyts.net:6969/announce", "http://tr.nyacat.pw:80/announce", "udp://tracker.opentrackr.org:1337/announce", "udp://tracker.qu.ax:6969/announce", "udp://tracker.dler.org:6969/announce", "udp://opentracker.io:6969/announce", "udp://explodie.org:6969/announce" ];'';

    patchStremioTrackers = pkgs.writeText "patch-stremio-trackers.js" ''
      const fs = require("fs");

      const serverPath = process.argv[2];
      const source = fs.readFileSync(serverPath, "utf8");
      const trackerModulePattern =
        /module\.exports = \[ (?:"(?:https?|udp):\/\/[^"\n]+\/announce"(?:, )?)+ \];/g;
      const matches = Array.from(source.matchAll(trackerModulePattern));

      if (matches.length !== 1) {
        throw new Error(
          "expected exactly one tracker module in " + serverPath + ", found " + matches.length,
        );
      }

      const replacement = ${builtins.toJSON trackerList};
      fs.writeFileSync(serverPath, source.replace(matches[0][0], replacement));
    '';

    stremioServer = pkgs.runCommand "stremio-server-http-trackers" {
      nativeBuildInputs = [ pkgs.nodejs ];
    } ''
      server_js=${pkgs.stremio-linux-shell}/libexec/stremio/server.js
      if ! test -f "$server_js"; then
        server_js=${pkgs.stremio-linux-shell}/share/stremio/server.js
      fi

      install -Dm644 "$server_js" $out/share/stremio/server.js
      node ${patchStremioTrackers} $out/share/stremio/server.js
    '';
    stremioWeb = pkgs.writeShellApplication {
      name = "stremio";
      runtimeInputs = [
        pkgs.coreutils
        pkgs.curl
        pkgs.nodejs
        pkgs.procps
        pkgs.util-linux
        pkgs.xdg-utils
      ];
      text = ''
        server_js="${stremioServer}/share/stremio/server.js"
        server_url="http://127.0.0.1:11470/"
        app_url="https://app.strem.io/shell-v4.4/?streamingServer=http%3A%2F%2F127.0.0.1%3A11470"
        log_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/stremio"
        log_file="$log_dir/server.log"

        for pid in $(pgrep -f '/share/stremio/server[.]js' || true); do
          cmdline="$(tr '\0' ' ' <"/proc/$pid/cmdline" 2>/dev/null || true)"
          case "$cmdline" in
            *"$server_js"*) ;;
            ?*) kill "$pid" 2>/dev/null || true ;;
          esac
        done

        if ! curl --silent --fail --max-time 1 "$server_url" >/dev/null 2>&1; then
          mkdir -p "$log_dir"
          setsid node "$server_js" >>"$log_file" 2>&1 &

          for _ in $(seq 1 50); do
            if curl --silent --fail --max-time 1 "$server_url" >/dev/null 2>&1; then
              break
            fi
            sleep 0.1
          done
        fi

        if command -v zen-beta >/dev/null 2>&1; then
          exec zen-beta --name stremio-web --new-window "$app_url"
        fi

        exec xdg-open "$app_url"
      '';
    };

    stremioIcon = pkgs.runCommand "stremio-icon" { } ''
      install -Dm644 \
        ${pkgs.stremio-linux-shell}/share/icons/hicolor/scalable/apps/com.stremio.Stremio.svg \
        $out/share/icons/hicolor/scalable/apps/com.stremio.Stremio.svg
    '';

  in
  {
    home.packages = [
      stremioWeb
      stremioIcon
    ];

    xdg.desktopEntries."com.stremio.Stremio" = {
      name = "Stremio";
      comment = "Freedom To Stream";
      exec = "stremio %U";
      icon = "com.stremio.Stremio";
      categories = [
        "Utility"
        "AudioVideo"
        "Video"
        "Player"
      ];
      mimeType = [ "x-scheme-handler/stremio" ];
      startupNotify = true;
      settings.Keywords = "Stremio;Media;Play;";
    };
  };
}
