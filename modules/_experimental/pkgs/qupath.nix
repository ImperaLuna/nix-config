{
  alsa-lib,
  atk,
  autoPatchelfHook,
  cairo,
  copyDesktopItems,
  dbus,
  expat,
  fetchurl,
  fontconfig,
  freetype,
  gdk-pixbuf,
  gsettings-desktop-schemas,
  glib,
  gtk3,
  harfbuzz,
  lib,
  libGL,
  libxkbcommon,
  libx11,
  libxau,
  libxcb,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxinerama,
  libxrandr,
  libxrender,
  libxtst,
  makeBinaryWrapper,
  makeDesktopItem,
  pango,
  stdenv,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qupath";
  version = "0.7.0";

  src = fetchurl {
    url = "https://github.com/qupath/qupath/releases/download/v${finalAttrs.version}/QuPath-v${finalAttrs.version}-Linux.tar.xz";
    hash = "sha256-Fl4noHMdWLoDnp0NNKVKz4lruS6BkiNw3ylcuFQYzlM=";
  };

  sourceRoot = "QuPath";
  dontBuild = true;

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    makeBinaryWrapper
  ];

  buildInputs = [
    alsa-lib
    atk
    cairo
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    gsettings-desktop-schemas
    glib
    gtk3
    harfbuzz
    libGL
    libxkbcommon
    libx11
    libxau
    libxcb
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxinerama
    libxrandr
    libxrender
    libxtst
    pango
    stdenv.cc.cc.lib
    zlib
  ];

  preFixup = ''
    addAutoPatchelfSearchPath "$out/opt/QuPath/lib"
    addAutoPatchelfSearchPath "$out/opt/QuPath/lib/runtime/lib"
    addAutoPatchelfSearchPath "$out/opt/QuPath/lib/runtime/lib/server"
  '';

  qupathRuntimeLibraryPath = lib.makeLibraryPath [
    alsa-lib
    atk
    cairo
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    gsettings-desktop-schemas
    glib
    gtk3
    harfbuzz
    libGL
    libxkbcommon
    libx11
    libxau
    libxcb
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxinerama
    libxrandr
    libxrender
    libxtst
    pango
    stdenv.cc.cc.lib
    zlib
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "qupath";
      desktopName = "QuPath";
      comment = "Open-source software for bioimage analysis";
      exec = "qupath %F";
      icon = "qupath";
      terminal = false;
      categories = [ "Science" "Education" "Graphics" ];
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/opt" "$out/bin" "$out/share/icons/hicolor/512x512/apps"
    cp -r . "$out/opt/QuPath"
    makeWrapper "$out/opt/QuPath/bin/QuPath" "$out/bin/qupath" \
      --prefix LD_LIBRARY_PATH : "$out/opt/QuPath/lib:$out/opt/QuPath/lib/runtime/lib:$out/opt/QuPath/lib/runtime/lib/server:${finalAttrs.qupathRuntimeLibraryPath}" \
      --prefix XDG_DATA_DIRS : "$out/share:${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}:${gtk3}/share/gsettings-schemas/${gtk3.name}:${gtk3}/share:${gdk-pixbuf}/share:${glib}/share"
    install -Dm644 "$out/opt/QuPath/lib/QuPath.png" "$out/share/icons/hicolor/512x512/apps/qupath.png"

    runHook postInstall
  '';

  meta = {
    description = "Digital pathology and bioimage analysis software";
    homepage = "https://qupath.github.io/";
    license = lib.licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "qupath";
  };
})
