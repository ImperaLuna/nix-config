{ ... }:

{
  flake.modules.homeManager.terminal-feature-llm-cli-tools = { pkgs, ... }:
    let
      omp = pkgs.stdenvNoCC.mkDerivation rec {
        pname = "omp";
        version = "16.2.2";

        src = pkgs.fetchurl {
          url = "https://github.com/can1357/oh-my-pi/releases/download/v${version}/omp-linux-x64";
          hash = "sha256-XP34rq0x71OVlrils/GukcKwx/aqGJ+sJPc8auN/L/s=";
        };

        dontUnpack = true;
        nativeBuildInputs = [ pkgs.makeWrapper ];

        installPhase = ''
          runHook preInstall

          install -Dm755 $src $out/libexec/omp
          makeWrapper ${pkgs.stdenv.cc.bintools.dynamicLinker} $out/bin/omp \
            --add-flags $out/libexec/omp

          runHook postInstall
        '';
      };
    in
    {
      home.packages = [
        pkgs.claude-code
        pkgs.codex
        pkgs.opencode
        omp
      ];
    };
}
