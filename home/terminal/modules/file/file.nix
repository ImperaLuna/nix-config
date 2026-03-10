{ pkgs, lib, config, ... }:

{
  options.modules.file.enable = lib.mkEnableOption "file";

  config = lib.mkIf config.modules.file.enable {
    home.packages = [ pkgs.file ];
  };
}
