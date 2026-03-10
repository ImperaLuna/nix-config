{ pkgs, lib, config, ... }:

{
  options.modules.tealdeer.enable = lib.mkEnableOption "tealdeer";

  config = lib.mkIf config.modules.tealdeer.enable {
    home.packages = [ pkgs.tealdeer ];

    xdg.configFile."tealdeer/config.toml".source = ./assets/config.toml;

    home.activation.updateTealdeerCache = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      cache_dir="$HOME/.cache/tealdeer/pages"

      if [ ! -d "$cache_dir" ] || [ -z "$(${pkgs.findutils}/bin/find "$cache_dir" -type f -print -quit 2>/dev/null)" ]; then
        ${pkgs.tealdeer}/bin/tldr --update >/dev/null 2>&1 || \
          echo "warning: failed to initialize tealdeer cache" >&2
      fi
    '';
  };
}
