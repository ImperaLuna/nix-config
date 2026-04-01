{ stdenvNoCC, fetchurl, makeDesktopItem, copyDesktopItems, lib }:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "qupath";
  version = "0.7.0";

  src = fetchurl {
    url = "https://github.com/qupath/qupath/releases/download/v${finalAttrs.version}/QuPath-v${finalAttrs.version}-Linux.tar.xz";
    hash = "sha256-Fl4noHMdWLoDnp0NNKVKz4lruS6BkiNw3ylcuFQYzlM=";
  };

  sourceRoot = "QuPath";
  dontBuild = true;

  nativeBuildInputs = [ copyDesktopItems ];

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
    ln -s "$out/opt/QuPath/bin/QuPath" "$out/bin/qupath"
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
