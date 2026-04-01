{ lib, config, pkgs, ... }:

{
  options.modules.homelab.enable = lib.mkEnableOption "homelab tools and services";

  config = lib.mkIf config.modules.homelab.enable {
    virtualisation.docker = {
      enable = true;
      autoPrune.enable = true;
    };

    environment.systemPackages = with pkgs; [
      docker-compose
    ];
  };
}
