{ pkgs, lib, config, ... }:

{
  options.modules.fd.enable = lib.mkEnableOption "fd";

  config = lib.mkIf config.modules.fd.enable {
    home.packages = [ pkgs.fd ];
  };
}
