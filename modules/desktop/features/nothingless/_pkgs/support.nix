{ pkgs }:

let
  axctl = pkgs.stdenv.mkDerivation {
    pname = "axctl";
    version = "unstable-2026-05-29";

    src = pkgs.fetchFromGitHub {
      owner = "Leriart";
      repo = "axctl.c";
      rev = "ff417df8270c4b28362064ea60a07cb93de6d69a";
      hash = "sha256-7tJcrGCjPND7ihwB9LSxWRJOLvq6Ago0doL40L7j2sU=";
    };

    nativeBuildInputs = [ pkgs.pkg-config ];
    buildInputs = [ pkgs.json_c pkgs.wayland ];

    installPhase = ''
      mkdir -p $out/bin
      install -Dm755 axctl $out/bin/axctl
    '';
  };

  phosphorIcons = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "ttf-phosphor-icons";
    version = "2.1.2";

    src = pkgs.fetchzip {
      url = "https://github.com/phosphor-icons/web/archive/refs/tags/v${version}.zip";
      sha256 = "sha256-96ivFjm0cBhqDKNB50klM7D3fevt8X9Zzm82KkJKMtU=";
      stripRoot = true;
    };

    dontBuild = true;

    installPhase = ''
      runHook preInstall
      install -Dm644 src/*/*.ttf -t $out/share/fonts/truetype
      install -Dm644 LICENSE -t $out/share/licenses/${pname}
      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "A flexible icon family for interfaces, diagrams, presentations";
      homepage = "https://phosphoricons.com";
      license = licenses.mit;
      platforms = platforms.all;
    };
  };
in
{
  inherit axctl phosphorIcons;

  packages = [
    axctl
    phosphorIcons
  ];
}
