{ pkgs, lib, ... }:

{
  home.packages = [ pkgs.bat ];

  xdg.configFile."bat/config".source =
    ../../../home/terminal/modules/bat/assets/config;
  xdg.configFile."bat/themes/Catppuccin Mocha.tmTheme".source =
    ../../../home/terminal/modules/bat/assets/themes + "/Catppuccin Mocha.tmTheme";

  home.activation.rebuildBatCache = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.bat}/bin/bat cache --build >/dev/null 2>&1 || \
      echo "warning: failed to rebuild bat theme cache" >&2
  '';
}
