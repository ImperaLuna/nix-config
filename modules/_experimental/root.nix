{ lib, appimageTools, fetchurl, runCommand, unzip }:

let
  pname = "root";
  version = "0.9.159";

  # Versioned Velopack package from Root's release feed
  # (installer/Linux/X64/releases.linux.json). The hash is the SHA256 the
  # feed publishes. The download page's Root.AppImage URL is unversioned and
  # changes on every release, so it can't be pinned.
  nupkg = fetchurl {
    url = "https://installer.rootapp.com/installer/Linux/X64/Root-${version}-linux-full.nupkg";
    hash = "sha256-Q8/MzEm4EL2V0JpHYHYfGbKy9EsSsC21uX9VHdJRNrE=";
  };

  # The nupkg is a zip holding the same AppImage the download page serves.
  src = runCommand "Root-${version}.AppImage" { nativeBuildInputs = [ unzip ]; } ''
    unzip -p ${nupkg} lib/app/Root.AppImage > $out
  '';

  contents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = pkgs: with pkgs; [
    # .NET runtime
    icu
    openssl
    krb5
    # SkiaSharp
    fontconfig
    # libuiohook, global keybinds (X11 only)
    libxtst
    libxt
    libxinerama
    libxkbcommon
    # Bundled Chromium (DotNetBrowser)
    nss
    nspr
    libgbm
    cups
    at-spi2-atk
    alsa-lib
    libpulseaudio
    pipewire
    # Calls /bin/ps to kill orphaned Chromium processes
    procps
  ];

  extraInstallCommands = ''
    install -Dm444 ${contents}/Root.desktop $out/share/applications/root.desktop
    substituteInPlace $out/share/applications/root.desktop \
      --replace-fail 'Exec=Root' 'Exec=root' \
      --replace-fail 'Icon=Root' 'Icon=root'
    install -Dm444 ${contents}/Root.png $out/share/icons/hicolor/512x512/apps/root.png
  '';

  meta = {
    description = "Root community chat app (upstream AppImage)";
    homepage = "https://www.rootapp.com";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "root";
  };
}
