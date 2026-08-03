{ ... }:

{
  flake.modules.homeManager.apps-feature-stremio = { pkgs, ... }:
  let
    trackerList = ''module.exports = [ "http://tracker.opentrackr.org:1337/announce", "http://tracker.tritan.gg:8080/announce", "http://tracker.renfei.net:8080/announce", "http://tracker.qu.ax:6969/announce", "http://tracker.dhitechnical.com:6969/announce", "http://t.overflow.biz:6969/announce", "http://bittorrent-tracker.e-n-c-r-y-p-t.net:1337/announce", "http://004430.xyz:80/announce", "http://tracker2.dler.org:80/announce", "http://tracker.dler.org:6969/announce", "http://tracker.dler.com:6969/announce", "http://tracker.bt4g.com:2095/announce", "http://tracker.waaa.moe:6969/announce", "http://tracker.skyts.net:6969/announce", "http://tr.nyacat.pw:80/announce", "udp://tracker.opentrackr.org:1337/announce", "udp://tracker.qu.ax:6969/announce", "udp://tracker.dler.org:6969/announce", "udp://opentracker.io:6969/announce", "udp://explodie.org:6969/announce" ];'';

    stremioSource = pkgs.stremio-linux-shell.src;

    patchStremioServer = pkgs.writeText "patch-stremio-server.js" ''
      const fs = require("fs");

      const serverPath = process.argv[2];
      let source = fs.readFileSync(serverPath, "utf8");
      const trackerModulePattern =
        /module\.exports = \[ (?:"(?:https?|udp):\/\/[^"\n]+\/announce"(?:, )?)+ \];/g;
      const trackerMatches = Array.from(source.matchAll(trackerModulePattern));

      if (trackerMatches.length !== 1) {
        throw new Error(
          "expected exactly one tracker module in " + serverPath + ", found " + trackerMatches.length,
        );
      }

      const trackerReplacement = ${builtins.toJSON trackerList};
      source = source.replace(trackerMatches[0][0], trackerReplacement);

      const mpvPath = 'path: [ "/usr/bin/mpv" ]';
      if (source.split(mpvPath).length !== 2) {
        throw new Error("expected exactly one mpv path in " + serverPath);
      }

      source = source.replace(
        mpvPath,
        'path: [ process.env.MPV_BIN || "/usr/bin/mpv" ]',
      );
      fs.writeFileSync(serverPath, source);
    '';

    stremioMpv = pkgs.writeShellApplication {
      name = "stremio-mpv";
      text = ''
        exec ${pkgs.mpv}/bin/mpv \
          --vo=gpu-next \
          --gpu-api=vulkan \
          --hwdec=nvdec-copy \
          "$@"
      '';
    };
    stremioServer = pkgs.runCommand "stremio-server-http-trackers" {
      nativeBuildInputs = [ pkgs.nodejs ];
    } ''
      server_js=${stremioSource}/data/server.js

      install -Dm644 "$server_js" $out/share/stremio/server.js
      node ${patchStremioServer} $out/share/stremio/server.js
    '';
    stremioNativePackage = pkgs.stremio-linux-shell.overrideAttrs (oldAttrs: {
      nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ pkgs.nodejs ];
      postPatch = (oldAttrs.postPatch or "") + ''
        node ${patchStremioServer} data/server.js
      '';
    });
    configureStremioNvenc = pkgs.writeText "configure-stremio-nvenc.js" ''
      const fs = require("fs");
      const path = require("path");

      const settingsPath = process.argv[2];
      let settings = {};

      try {
        settings = JSON.parse(fs.readFileSync(settingsPath, "utf8"));
      } catch (error) {
        if (error.code !== "ENOENT") {
          throw error;
        }
      }

      const changed =
        settings.transcodeHardwareAccel !== true || settings.transcodeProfile !== "nvenc-linux";

      if (changed) {
        settings.transcodeHardwareAccel = true;
        settings.transcodeProfile = "nvenc-linux";
        fs.mkdirSync(path.dirname(settingsPath), { recursive: true });
        const temporaryPath = settingsPath + "." + process.pid + ".tmp";
        fs.writeFileSync(temporaryPath, JSON.stringify(settings, null, 4) + "\n");
        fs.renameSync(temporaryPath, settingsPath);
      }

      process.stdout.write(changed ? "1" : "0");
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
        settings_file="$HOME/.stremio-server/server-settings.json"
        restart_server=0
        export MPV_BIN="${stremioMpv}/bin/stremio-mpv"

        if [[ -e /dev/nvidia0 ]]; then
          restart_server="$(node ${configureStremioNvenc} "$settings_file")"
        fi

        for pid in $(pgrep -f '/share/stremio/server[.]js' || true); do
          cmdline="$(tr '\0' ' ' <"/proc/$pid/cmdline" 2>/dev/null || true)"
          case "$cmdline" in
            *"$server_js"*)
              if [[ "$restart_server" != 1 ]]; then
                continue
              fi
              ;;
            "") continue ;;
          esac

          kill "$pid" 2>/dev/null || true
          for _ in $(seq 1 20); do
            if ! kill -0 "$pid" 2>/dev/null; then
              break
            fi
            sleep 0.05
          done
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
    stremioNative = pkgs.writeShellApplication {
      name = "stremio-native";
      runtimeInputs = [
        pkgs.coreutils
        pkgs.procps
      ];
      text = ''
        for pid in $(pgrep -f '/share/stremio/server[.]js' || true); do
          kill "$pid" 2>/dev/null || true
          for _ in $(seq 1 20); do
            if ! kill -0 "$pid" 2>/dev/null; then
              break
            fi
            sleep 0.05
          done
        done

        export MPV_BIN="${stremioMpv}/bin/stremio-mpv"
        exec ${stremioNativePackage}/bin/stremio "$@"
      '';
    };

    stremioIcon = pkgs.runCommand "stremio-icon" { } ''
      install -Dm644 \
        ${stremioSource}/data/icons/com.stremio.Stremio.svg \
        $out/share/icons/hicolor/scalable/apps/com.stremio.Stremio.svg
    '';

  in
  {
    home.packages = [
      stremioWeb
      stremioNative
      stremioIcon
    ];

    xdg.desktopEntries."com.stremio.Stremio" = {
      name = "Stremio (Web)";
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
      settings.Keywords = "Stremio;Media;Play;Web;";
    };

    xdg.desktopEntries."com.stremio.Stremio.Native" = {
      name = "Stremio (Native)";
      comment = "Freedom To Stream with native video playback";
      exec = "stremio-native %U";
      icon = "com.stremio.Stremio";
      categories = [
        "Utility"
        "AudioVideo"
        "Video"
        "Player"
      ];
      startupNotify = true;
      settings = {
        Keywords = "Stremio;Media;Play;Native;";
        StartupWMClass = "com.stremio.Stremio";
      };
    };
  };
}
