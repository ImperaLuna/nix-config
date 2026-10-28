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
              rev = "452aa63735f6909045c4ffe40f65859f42ef8888";
              fetchSubmodules = true;
              hash = "sha256-C3NHOIfaWncVDIDL3++3OX/pnjvBtfb4FNKnWggrKTY=";
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
