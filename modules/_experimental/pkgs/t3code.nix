{ appimageTools, fetchurl, lib }:

appimageTools.wrapType2 {
  pname = "t3code";
  version = "0.0.31";

  src = fetchurl {
    url = "https://github.com/pingdotgg/t3code/releases/download/v0.0.31/T3-Code-0.0.31-x86_64.AppImage";
    hash = "sha256-AqTkoSKeQwmql3L9F5SbD1XyqeFyqe11ciq9Tp04Zyw=";
  };

  meta = {
    description = "Agent harness control surface";
    homepage = "https://github.com/pingdotgg/t3code";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}
