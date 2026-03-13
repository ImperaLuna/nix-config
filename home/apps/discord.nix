{ lib, config, pkgs, ... }:

{
  options.modules.discord.enable = lib.mkEnableOption "discord";

  config = lib.mkIf config.modules.discord.enable {
    home.packages = [ pkgs.discord ];
  };
}
