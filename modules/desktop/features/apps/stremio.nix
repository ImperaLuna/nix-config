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
    stremioNativePackage = pkgs.stremio-linux-shell.overrideAttrs (oldAttrs: {
      nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ pkgs.nodejs ];
      postPatch = (oldAttrs.postPatch or "") + ''
        node ${patchStremioServer} data/server.js
      '';
    });
    stremio = pkgs.writeShellApplication {
      name = "stremio";
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
      stremio
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
      settings = {
        Keywords = "Stremio;Media;Play;";
        StartupWMClass = "com.stremio.Stremio";
      };
    };
  };
}
