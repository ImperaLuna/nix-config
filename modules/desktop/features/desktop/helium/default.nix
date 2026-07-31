{ lib, ... }:

{
  flake.modules.homeManager.desktop-feature-helium = { pkgs, ... }:
    let
      version = "0.15.1.1";
      src = pkgs.fetchurl {
        url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-x86_64.AppImage";
        hash = "sha256-qz3w+nnvBgkpHT3E34dv4DvFuYlyzTAyg9tPYJFWs3o=";
      };

      appimageContents = pkgs.appimageTools.extractType2 { inherit src version; pname = "helium"; };

      helium = pkgs.appimageTools.wrapType2 {
        pname = "helium";
        inherit version src;

        extraInstallCommands = ''
          install -Dm444 ${appimageContents}/helium.desktop $out/share/applications/helium.desktop
          install -Dm444 ${appimageContents}/helium.png $out/share/icons/hicolor/256x256/apps/helium.png
        '';

        meta = {
          description = "Private, fast, and reliable web browser";
          homepage = "https://github.com/imputnet/helium";
          license = lib.licenses.gpl3Only;
          mainProgram = "helium";
          platforms = [ "x86_64-linux" ];
          sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
        };
      };
    in
    {
      home.packages = [ helium ];
    };
}
