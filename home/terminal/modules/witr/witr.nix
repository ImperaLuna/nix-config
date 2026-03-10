{ pkgs, lib, config, ... }:

{
  options.modules.witr.enable = lib.mkEnableOption "witr";

  config = lib.mkIf config.modules.witr.enable {
    home.packages = [ pkgs.witr ];
  };
}
