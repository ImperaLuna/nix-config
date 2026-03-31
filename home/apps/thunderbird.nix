{ lib, config, pkgs, ... }:

{
  options.modules.thunderbird.enable = lib.mkEnableOption "thunderbird";

  config = lib.mkIf config.modules.thunderbird.enable {
    home.packages = [ pkgs.thunderbird ];
  };
}
