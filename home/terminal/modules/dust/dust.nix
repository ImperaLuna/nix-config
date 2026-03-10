{ pkgs, lib, config, ... }:

{
  options.modules.dust.enable = lib.mkEnableOption "dust";

  config = lib.mkIf config.modules.dust.enable {
    home.packages = [ pkgs.dust ];
  };
}
