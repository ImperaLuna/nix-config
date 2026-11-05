# Flea, the Omarchy file manager (github.com/thisisgm/flea).
# Flea hardcodes /usr paths and links into Omarchy's shell, so the binaries
# run inside an FHS env that puts Flea and Omarchy's files under /usr.
{
  lib,
  rustPlatform,
  fetchFromGitHub,
  buildFHSEnv,
  pkg-config,
  python3,
  # Linked or dlopened by flea-gui.
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  libheif,
  libglvnd,
  libxkbcommon,
  mpv,
  poppler,
  vulkan-loader,
  wayland,
  libx11,
  libxcb,
  # Runtime tools from the PKGBUILD's depends.
  bat,
  bubblewrap,
  expect,
  gvfs,
  jq,
  ripgrep,
  shared-mime-info,
  udisks,
  usbmuxd,
  util-linux,
  wl-clipboard,
  xdg-terminal-exec,
  xdg-utils,
  quickjs-ng,
  qt6,
  hicolor-icon-theme,
  p7zip,
  ffmpeg,
  ffmpegthumbnailer,
  libarchive,
  zoxide,
}:

let
  version = "0.4.0";

  # Omarchy's shell QML (Commons, Ui) and themes, which Flea reads from /usr/share/omarchy.
  omarchy = fetchFromGitHub {
    owner = "basecamp";
    repo = "omarchy";
    rev = "5f2fb785562b2b6cd9a58787a3bfd673568fe9dd";
    hash = "sha256-M953IMrIKnEuxY8GDa8/RXEpChlR+MFn39XCv8dANMY=";
  };

  libs = [
    fontconfig
    freetype
    gdk-pixbuf
    glib
    libheif
    libglvnd
    libxkbcommon
    mpv
    poppler
    vulkan-loader
    wayland
    libx11
    libxcb
  ];

  unwrapped = rustPlatform.buildRustPackage {
    pname = "flea-unwrapped";
    inherit version;

    src = fetchFromGitHub {
      owner = "thisisgm";
      repo = "flea";
      tag = "v${version}";
      hash = "sha256-zzGFgcpA2D3AwGKjt8H1cz9mwi/i/iqBNB4xLl35bZg=";
    };

    cargoLock = {
      lockFile = "${unwrapped.src}/Cargo.lock";
      allowBuiltinFetchGit = true;
    };

    nativeBuildInputs = [ pkg-config ];
    buildInputs = libs;

    cargoBuildFlags = [
      "--workspace"
      "--bins"
    ];
    # The suites need bwrap namespaces and thumbnailers the sandbox lacks.
    doCheck = false;

    # Upstream's Makefile reads target/release and installs into DESTDIR/usr.
    postInstall = ''
      mkdir -p target/release
      cp $out/bin/flea $out/bin/flea-gui target/release/
      rm -r $out/bin
      make DESTDIR=$out VERSION=${version}-1 install
      mv $out/usr/* $out/
      rmdir $out/usr
      rm -r $out/share/libalpm
    '';

    meta = {
      description = "Fast, keyboard-first file manager for Omarchy";
      homepage = "https://github.com/thisisgm/flea";
      license = lib.licenses.mit;
      platforms = [ "x86_64-linux" ];
    };
  };
in
buildFHSEnv {
  pname = "flea";
  inherit version;

  targetPkgs = _: libs ++ [
    unwrapped
    bat
    bubblewrap
    expect
    gvfs
    jq
    ripgrep
    shared-mime-info
    udisks
    usbmuxd
    util-linux
    wl-clipboard
    xdg-terminal-exec
    xdg-utils
    quickjs-ng
    qt6.qtdeclarative
    qt6.qtwebengine
    hicolor-icon-theme
    p7zip
    ffmpeg
    ffmpegthumbnailer
    libarchive
    zoxide
    (python3.withPackages (ps: [ ps.pygobject3 ]))
  ];

  extraBuildCommands = ''
    mkdir -p usr/share/omarchy
    ln -s ${omarchy}/shell usr/share/omarchy/shell
    ln -s ${omarchy}/themes usr/share/omarchy/themes
  '';

  runScript = "/usr/bin/flea";

  extraInstallCommands = ''
    mkdir -p $out/share
    ln -s ${unwrapped}/share/applications $out/share/applications
    ln -s ${unwrapped}/share/icons $out/share/icons
  '';

  passthru = { inherit unwrapped omarchy; };
  inherit (unwrapped) meta;
}
