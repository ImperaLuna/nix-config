{
  appimageTools,
  fetchurl,
  lib,
  makeDesktopItem,
}:

let
  pname = "headlamp";
  version = "0.41.0";

  src = fetchurl {
    url = "https://github.com/kubernetes-sigs/headlamp/releases/download/v${version}/Headlamp-${version}-linux-x64.AppImage";
    hash = "sha256-SdadGirmfSfj1gmbxc5IKRdwnHqkI4keSE0BlkKGW4c=";
  };

  desktopItem = makeDesktopItem {
    name = pname;
    desktopName = "Headlamp";
    comment = "Kubernetes web UI desktop application";
    exec = "headlamp %U";
    terminal = false;
    categories = [ "Development" "System" "Utility" ];
    startupNotify = true;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    mkdir -p "$out/share/applications"
    cp ${desktopItem}/share/applications/* "$out/share/applications/"
  '';

  meta = {
    description = "Easy-to-use and extensible Kubernetes UI";
    homepage = "https://headlamp.dev/";
    license = lib.licenses.asl20;
    mainProgram = "headlamp";
    platforms = [ "x86_64-linux" ];
  };
}
