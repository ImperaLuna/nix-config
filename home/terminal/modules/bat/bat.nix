{ pkgs, lib, config, ... }:

{
  options.modules.bat.enable = lib.mkEnableOption "bat";

  config = lib.mkIf config.modules.bat.enable {
    home.packages = [ pkgs.bat ];

    xdg.configFile."bat/config".source = ./assets/config;
    xdg.configFile."bat/themes/Catppuccin Mocha.tmTheme".source =
      ./assets/themes + "/Catppuccin Mocha.tmTheme";

    home.activation.rebuildBatCache = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ${pkgs.bat}/bin/bat cache --build >/dev/null 2>&1 || \
        echo "warning: failed to rebuild bat theme cache" >&2
    '';
  };
}
