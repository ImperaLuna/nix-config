{ ... }:

{
  # Temporary/experimental packages live here.
  # Keep entries commented by default and enable only while testing.
  flake.modules.homeManager.experimental = { pkgs, ... }:
    let
      # Mandara Shell (https://github.com/theHamdiz/mandara): Rust + GPUI
      # bar, dock, launcher and notifications for Hyprland, Niri and MangoWM.
      # Prebuilt release binary. Start it by hand with `mandara`; skip
      # `mandara setup`, which writes an include line into hyprland.conf.
      mandara = pkgs.stdenv.mkDerivation rec {
        pname = "mandara";
        version = "0.1.0";

        src = pkgs.fetchurl {
          url = "https://github.com/theHamdiz/mandara/releases/download/v${version}/mandara-${version}-x86_64-linux-gnu.tar.gz";
          hash = "sha256-6Yl+B3YtVKOj8lx5LwaPgiCss25o72ErsKsx4EcZoTw=";
        };

        nativeBuildInputs = [ pkgs.autoPatchelfHook ];
        buildInputs = [ pkgs.libxkbcommon pkgs.stdenv.cc.cc.lib ];

        # Loaded with dlopen at runtime, so autoPatchelf adds them to RPATH.
        runtimeDependencies = with pkgs; [
          wayland
          vulkan-loader
          libxkbcommon
          fontconfig
          freetype
          linux-pam
        ];

        dontStrip = true;

        installPhase = ''
          runHook preInstall
          install -Dm755 bin/mandara $out/bin/mandara
          install -Dm644 share/applications/org.mandara.studio.desktop -t $out/share/applications
          install -Dm644 share/icons/hicolor/scalable/apps/org.mandara.studio.svg -t $out/share/icons/hicolor/scalable/apps
          runHook postInstall
        '';
      };
    in
    {
      home.packages = [
        # pkgs.alacritty
        # pkgs.google-chrome
        mandara
      ];

    };
}
