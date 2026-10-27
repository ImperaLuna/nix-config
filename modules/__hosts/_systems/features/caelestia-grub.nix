{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.boot.loader.grub.caelestia;
  src = inputs.caelestia-grub;

  # Badges are a flat fill with a dark glyph (#171322). Moving each channel
  # linearly from the old fill to the new one keeps the anti-aliased edges.
  recolour = from: to: input: output:
    let
      ink = [ 23 19 34 ];
      channel = i: name:
        let
          k = builtins.elemAt ink i;
          a = builtins.elemAt from i;
          b = builtins.elemAt to i;
        in
        "-channel ${name} -fx '(${toString k} + (u*255-${toString k})*(${toString (b - k)})/(${toString (a - k)}))/255'";
    in
    "magick ${input} ${channel 0 "R"} ${channel 1 "G"} ${channel 2 "B"} +channel ${output}";

  theme = pkgs.runCommand "caelestia-grub-theme" { nativeBuildInputs = [ pkgs.imagemagick ]; } ''
    cp -r ${src}/theme $out
    chmod -R u+w $out
    cd $out/icons
    # Orange badge for the default entry, picked by the nixos-current class.
    ${recolour [ 185 223 255 ] cfg.currentColour "nixos.png" "nixos-current.png"}
    ${recolour [ 188 235 220 ] cfg.windowsColour "windows.png" "windows.png"}
  '';
in
{
  options.boot.loader.grub.caelestia = {
    enable = lib.mkEnableOption "the Caelestia GRUB carousel";

    currentColour = lib.mkOption {
      type = lib.types.listOf lib.types.int;
      default = [ 255 189 138 ];
      description = "RGB fill of the badge on the default NixOS entry.";
    };

    windowsColour = lib.mkOption {
      type = lib.types.listOf lib.types.int;
      default = [ 160 200 255 ];
      description = "RGB fill of the Windows badge.";
    };
  };

  config = lib.mkIf cfg.enable {
    # The carousel lives in GRUB's C code, so the theme only works with this build.
    # nixpkgs ships the same GRUB 2.14 the patch targets. The GRUB module has no
    # package option and reads pkgs.grub2 directly.
    nixpkgs.overlays = [
      (_final: prev: {
        grub2 = prev.grub2.overrideAttrs (old: {
          patches = (old.patches or [ ]) ++ [ "${src}/src/grub.patch" ];
        });
      })
    ];

    boot.loader.grub = {
      inherit theme;
      # Classes pick the badge. GRUB uses the first class that has an icon.
      entryOptions = "--class nixos-current --class nixos --unrestricted";

      # NixOS always points at theme.txt; the patch only switches to the
      # carousel layout when the theme path ends in /carousel.txt.
      extraConfig = ''
        insmod regexp
        if regexp --set=1:caelestia_theme_dir '^(.*)/theme\.txt$' "$theme"; then
          set theme="$caelestia_theme_dir/carousel.txt"
          export theme
        fi
        set caelestia_carousel=1
        export caelestia_carousel
        set caelestia_motion=1
        export caelestia_motion
      '';
    };
  };
}
