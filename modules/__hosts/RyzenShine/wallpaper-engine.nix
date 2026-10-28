{ ... }:

{
  # linux-wallpaperengine pauses every monitor when one has a fullscreen window.
  # Build it from the fork with Almamu/linux-wallpaperengine#705, which adds
  # --fullscreen-pause-per-monitor, and always pass that flag, since Nova's
  # engine flags are fixed. Drop this once #705 lands in nixpkgs and Nova passes the flag.
  nixpkgs.overlays = [
    (_final: prev: {
      linux-wallpaperengine =
        let
          patched = prev.linux-wallpaperengine.overrideAttrs (old: {
            version = "0.0.1-unstable-2026-10-28-per-monitor";
            src = prev.fetchFromGitHub {
              owner = "ImperaLuna";
              repo = "linux-wallpaperengine";
              rev = "35a0960d80e3a47c213d69a388432bba9821def3";
              fetchSubmodules = true;
              hash = "sha256-3FvnFiLGR9V/0X5C0nYgBWAiUWfFvUZCi5JcaEm4NQE=";
            };
          });
        in
        prev.symlinkJoin {
          name = "linux-wallpaperengine-${patched.version}";
          paths = [ patched ];
          nativeBuildInputs = [ prev.makeWrapper ];
          postBuild = ''
            rm $out/bin/linux-wallpaperengine
            makeWrapper ${patched}/bin/linux-wallpaperengine $out/bin/linux-wallpaperengine \
              --add-flags --fullscreen-pause-per-monitor
          '';
          inherit (patched) meta;
        };
    })
  ];
}
