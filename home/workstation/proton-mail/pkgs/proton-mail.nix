{
  lib,
  stdenvNoCC,
  autoPatchelfHook,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  dpkg,
  fetchurl,
  gtk3,
  glib,
  nss,
  nspr,
  dbus,
  atk,
  at-spi2-atk,
  at-spi2-core,
  mesa,
  libdrm,
  libgbm,
  expat,
  libx11,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxrandr,
  libxrender,
  libxtst,
  libxcb,
  alsa-lib,
  cups,
  pango,
  cairo,
  libxkbcommon,
  udev,
  systemd,
  libnotify,
}:

let
  pname = "proton-mail";
  version = "1.12.1";

  src = fetchurl {
    url = "file:///home/imperaluna/Downloads/ProtonMail-desktop-beta.deb";
    hash = "sha256-CNrL/O2PMXaUVgvXbmrLFZphz7yV4BlRlr388nbMsoE=";
  };

  desktopItem = makeDesktopItem {
    name = pname;
    desktopName = "Proton Mail";
    genericName = "Proton Mail";
    comment = "Proton official desktop application for Proton Mail and Proton Calendar";
    exec = "proton-mail %U";
    icon = "proton-mail";
    categories = [ "Network" "Email" ];
    mimeTypes = [ "x-scheme-handler/mailto" ];
    startupNotify = true;
  };
in
stdenvNoCC.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    dpkg
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    atk
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libdrm
    libgbm
    libnotify
    libxkbcommon
    mesa
    nspr
    nss
    pango
    systemd
    udev
    libx11
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxrandr
    libxrender
    libxtst
    libxcb
  ];

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    runHook preUnpack
    mkdir -p unpacked
    dpkg-deb --fsys-tarfile "$src" | tar --no-same-owner --no-same-permissions -x -C unpacked
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin" "$out/lib" "$out/share"
    cp -r unpacked/usr/lib/proton-mail "$out/lib/"
    cp -r unpacked/usr/share/icons "$out/share/" 2>/dev/null || true
    cp -r unpacked/usr/share/pixmaps "$out/share/"
    chmod 0755 "$out/lib/proton-mail/chrome-sandbox"

    makeWrapper "$out/lib/proton-mail/Proton Mail Beta" "$out/bin/proton-mail" \
      --add-flags "--no-sandbox" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [
        alsa-lib
        atk
        at-spi2-atk
        at-spi2-core
        cairo
        cups
        dbus
        expat
        glib
        gtk3
        libdrm
        libgbm
        libnotify
        libxkbcommon
        mesa
        nspr
        nss
        pango
        systemd
        udev
        libx11
        libxcomposite
        libxcursor
        libxdamage
        libxext
        libxfixes
        libxi
        libxrandr
        libxrender
        libxtst
        libxcb
      ]}" \
      --set-default NIXOS_OZONE_WL 1

    runHook postInstall
  '';

  desktopItems = [ desktopItem ];

  meta = {
    description = "Proton official desktop application for Proton Mail and Proton Calendar";
    homepage = "https://proton.me";
    license = lib.licenses.unfree;
    mainProgram = "proton-mail";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
