{ stdenvNoCC, fetchurl, autoPatchelfHook, patchelf, curl, libxml2, sqlite, stdenv, lib }:

stdenvNoCC.mkDerivation {
  pname = "codexbar";
  version = "0.18.0-beta.3";

  src = fetchurl {
    url = "https://github.com/steipete/CodexBar/releases/download/v0.18.0-beta.3/CodexBarCLI-v0.18.0-beta.3-linux-x86_64.tar.gz";
    sha256 = "0h1yvj3qynjfbcs4phbilskh7c5vkmvphqhzkw2mv5szz3wmrmxd";
  };

  nativeBuildInputs = [ autoPatchelfHook patchelf ];
  buildInputs = [ curl (lib.getLib libxml2) sqlite stdenv.cc.cc.lib ];

  unpackPhase = ''
    tar xzf $src
  '';

  # libxml2 >= 2.13 changed its soname from libxml2.so.2 to libxml2.so.16
  preFixup = ''
    patchelf --replace-needed libxml2.so.2 libxml2.so.16 $out/bin/codexbar
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp CodexBarCLI $out/bin/codexbar
    chmod +x $out/bin/codexbar
  '';
}
