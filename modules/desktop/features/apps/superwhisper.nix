{ ... }:

{
  # Superwhisper dictation, packaged from the prebuilt Linux release.
  # Upstream's install.sh targets Arch/Debian/Fedora and its Nix flake is
  # private, so this repackages the release archive. Bump `version` and the
  # sha256 from https://tux.superwhisper.com/stable.json to update; the
  # in-app updater is disabled.
  flake.modules.homeManager.apps-feature-superwhisper = { pkgs, lib, ... }:
  let
    version = "1.3.1";

    python = pkgs.python3.withPackages (ps: [
      ps.pygobject3
      ps.pycairo
    ]);

    typelibs = [
      pkgs.glib.out
      pkgs.gobject-introspection
      pkgs.gtk4
      pkgs.gdk-pixbuf
      pkgs.pango.out
      pkgs.harfbuzz
      pkgs.graphene
      pkgs.at-spi2-core
      pkgs.gtk4-layer-shell
    ];

    runtimePath = [
      python
      pkgs.coreutils
      pkgs.gnutar
      pkgs.zstd
      pkgs.systemd
      pkgs.pulseaudio # pactl, parec, paplay
      pkgs.pipewire # pw-record
      pkgs.wl-clipboard
      pkgs.wtype
      pkgs.libnotify
      pkgs.ffmpeg
      pkgs.fontconfig
      pkgs.xdg-utils
      pkgs.desktop-file-utils
      pkgs.glibc.bin # ldd for `superwhisper doctor`
    ];

    superwhisper = pkgs.stdenv.mkDerivation {
      pname = "superwhisper";
      inherit version;

      src = pkgs.fetchurl {
        url = "https://github.com/superultrainc/superwhisper-linux-releases/releases/download/v${version}/superwhisper-omarchy-x86_64-${version}.tar.zst";
        sha256 = "464a732ca6c928d3f2b8bb94687176a75ca2b09c186333d34d94d051ccb5f0e4";
      };

      nativeBuildInputs = [
        pkgs.zstd
        pkgs.autoPatchelfHook
        pkgs.makeWrapper
      ];

      buildInputs = [
        pkgs.stdenv.cc.cc.lib # libstdc++, libgomp
        pkgs.vulkan-loader
        pkgs.gtk4
        pkgs.gdk-pixbuf
        pkgs.cairo
        pkgs.graphene
        pkgs.glib
        pkgs.libxcb
        pkgs.fontconfig
        pkgs.libxkbcommon
        pkgs.wayland
      ];

      # The fcitx5 input-method addon is optional and needs fcitx5 itself.
      autoPatchelfIgnoreMissingDeps = [
        "libFcitx5Core.so.7"
        "libFcitx5Utils.so.2"
      ];

      dontConfigure = true;
      dontBuild = true;

      installPhase = ''
        runHook preInstall

        app=$out/share/superwhisper/app
        mkdir -p $app
        cp -a app/. $app/
        patchShebangs $app/run.sh $app/scripts

        # ~/.config/hypr is a read-only store path, so the app writes its
        # Hyprland binds to this file instead. hyprland.lua loads it.
        makeWrapper $app/run.sh $out/bin/superwhisper \
          --set SUPERWHISPER_UPDATE_DISABLED 1 \
          --run 'export SUPERWHISPER_HYPR_BINDINGS="''${SUPERWHISPER_HYPR_BINDINGS:-''${XDG_CONFIG_HOME:-$HOME/.config}/superwhisper/hyprland-bindings.lua}"' \
          --run '[ -e "$SUPERWHISPER_HYPR_BINDINGS" ] || { mkdir -p "''${SUPERWHISPER_HYPR_BINDINGS%/*}" && : > "$SUPERWHISPER_HYPR_BINDINGS"; }' \
          --prefix PATH : ${lib.makeBinPath runtimePath} \
          --prefix GI_TYPELIB_PATH : ${lib.makeSearchPath "lib/girepository-1.0" typelibs} \
          --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [
            # The GPUI settings window loads these at runtime, not via NEEDED.
            pkgs.wayland
            pkgs.vulkan-loader
            pkgs.libxkbcommon
            pkgs.libGL
            pkgs.fontconfig
            pkgs.freetype
            pkgs.gtk4-layer-shell
          ]} \
          --set GDK_PIXBUF_MODULE_FILE ${pkgs.librsvg.out}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache

        for png in $app/assets/app-icon/*.png; do
          size=$(basename "$png" .png)
          install -Dm644 "$png" $out/share/icons/hicolor/''${size}x''${size}/apps/superwhisper.png
        done
        install -Dm644 $app/assets/linux-status/SuperwhisperTUI.ttf \
          $out/share/fonts/truetype/SuperwhisperTUI.ttf

        runHook postInstall
      '';

      meta = {
        description = "Superwhisper voice dictation";
        homepage = "https://superwhisper.com/linux";
        license = lib.licenses.unfree;
        platforms = [ "x86_64-linux" ];
        mainProgram = "superwhisper";
      };
    };
  in
  {
    home.packages = [ superwhisper ];

    systemd.user.services.superwhisper = {
      Unit = {
        Description = "Superwhisper dictation";
        After = [ "graphical-session.target" "pipewire.service" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${superwhisper}/bin/superwhisper daemon";
        ExecStopPost = [
          "${superwhisper}/bin/superwhisper playback-restore"
          "${superwhisper}/bin/superwhisper desktop-release"
        ];
        Restart = "on-failure";
        RestartSec = 2;
        KillMode = "control-group";
        TimeoutStopSec = 15;
        UMask = "0077";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    xdg.desktopEntries = {
      "com.superwhisper.Superwhisper" = {
        name = "Superwhisper";
        comment = "Fast local and cloud dictation";
        exec = "superwhisper settings --window";
        icon = "superwhisper";
        categories = [ "Utility" "Accessibility" ];
        settings.StartupWMClass = "com.superwhisper.Superwhisper";
      };
      # Handles the superwhisper:// links the website uses for license activation.
      superwhisper-url = {
        name = "Superwhisper License Activation";
        exec = "superwhisper open-url %u";
        icon = "superwhisper";
        noDisplay = true;
        mimeType = [ "x-scheme-handler/superwhisper" ];
      };
    };
  };
}
