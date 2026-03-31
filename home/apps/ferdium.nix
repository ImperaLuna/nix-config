{ lib, config, pkgs, ... }:

{
  options.modules.ferdium.enable = lib.mkEnableOption "ferdium";

  config = lib.mkIf config.modules.ferdium.enable {
    home.packages = [ pkgs.ferdium ];
  };
}
