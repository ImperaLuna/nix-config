{ lib, config, pkgs, ... }:

{
  options.modules.virtualisation.enable = lib.mkEnableOption "virtualisation";

  config = lib.mkIf config.modules.virtualisation.enable {
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;

    system.activationScripts.usrbinsh = ''
      mkdir -p /usr/bin
      ln -sf /run/current-system/sw/bin/sh /usr/bin/sh
    '';

    systemd.services."virt-secret-init-encryption".path = with pkgs; [ coreutils systemd ];
    systemd.tmpfiles.rules = [ "d /var/lib/libvirt/secrets 0700 root root -" ];
  };
}
