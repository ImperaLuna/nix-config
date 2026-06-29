{ ... }:

{
  flake.modules.homeManager.desktop-feature-cursor = { pkgs, ... }:
    let
      theme = import ../../_lib/themes/carbonfox.nix;
      cursorThemeName = "Bibata-Modern-Carbonfox";
      cursorSize = 24;

      carbonfoxBibataModern = pkgs.bibata-cursors.overrideAttrs (oldAttrs: {
        pname = "bibata-modern-carbonfox-cursors";

        nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ pkgs.imagemagick ];

        buildPhase = ''
          runHook preBuild

          mkdir -p bitmaps
          cp -r ${oldAttrs.bitmaps}/Bibata-Modern-Amber bitmaps/${cursorThemeName}
          chmod -R u+w bitmaps/${cursorThemeName}

          find bitmaps/${cursorThemeName} -type f -name '*.png' -print0 \
            | xargs -0 magick mogrify -alpha on -type TrueColorAlpha -define png:color-type=6 -fuzz 8% -fill '${theme.primary}' -opaque '#FF8300'

          ctgen configs/normal/x.build.toml \
            -p x11 \
            -d bitmaps/${cursorThemeName} \
            -n '${cursorThemeName}' \
            -c 'Carbonfox orange and rounded edge Bibata XCursors'

          runHook postBuild
        '';
      });
    in
    {
      home.pointerCursor = {
        enable = true;
        package = carbonfoxBibataModern;
        name = cursorThemeName;
        size = cursorSize;

        gtk.enable = true;
        x11.enable = true;
        dotIcons.enable = true;
      };

      gtk.cursorTheme = {
        package = carbonfoxBibataModern;
        name = cursorThemeName;
        size = cursorSize;
      };

      dconf.settings."org/gnome/desktop/interface" = {
        cursor-theme = cursorThemeName;
        cursor-size = cursorSize;
      };
    };
}
