{ lib, config, pkgs, ... }:

{
  options.modules.onlyoffice.enable = lib.mkEnableOption "onlyoffice";

  config = lib.mkIf config.modules.onlyoffice.enable {
    home.packages = [ pkgs.onlyoffice-desktopeditors ];
  };
}
