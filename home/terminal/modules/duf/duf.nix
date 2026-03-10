{ pkgs, lib, config, ... }:

{
  options.modules.duf.enable = lib.mkEnableOption "duf";

  config = lib.mkIf config.modules.duf.enable {
    home.packages = [ pkgs.duf ];
  };
}
