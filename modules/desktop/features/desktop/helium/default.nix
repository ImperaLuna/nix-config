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

      heliumOpen = pkgs.writeShellScript "helium-open" ''
        uri="$1"
        case "$uri" in
          helium-open://*)
            exec ${helium}/bin/helium "http://''${uri#helium-open://}"
            ;;
        esac

        echo "Unsupported Helium URL: $uri" >&2
        exit 2
      '';
    in
    {
      home.packages = [ helium ];

      xdg.desktopEntries.helium-open = {
        name = "Open URL in Helium";
        exec = "${heliumOpen} %u";
        icon = "helium";
        mimeType = [ "x-scheme-handler/helium-open" ];
        settings.NoDisplay = "true";
      };

      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "text/html" = [ "zen-beta.desktop" ];
          "application/xhtml+xml" = [ "zen-beta.desktop" ];
          "x-scheme-handler/http" = [ "zen-beta.desktop" ];
          "x-scheme-handler/https" = [ "zen-beta.desktop" ];
          "x-scheme-handler/helium-open" = [ "helium-open.desktop" ];
        };
      };
    };
}
