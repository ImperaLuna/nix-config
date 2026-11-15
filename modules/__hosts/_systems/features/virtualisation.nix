{ pkgs, ... }:

{
  virtualisation.libvirtd = {
    enable = true;
    qemu.swtpm.enable = true;
  };
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };
  # The rootless docker unit is a global user unit, so it also started for
  # the sddm greeter user, which has no subuid range, and failed every boot.
  systemd.user.services.docker.unitConfig.ConditionUser = "!@system";
  programs.virt-manager.enable = true;

  system.activationScripts.usrbinsh = ''
    mkdir -p /usr/bin
    ln -sf /run/current-system/sw/bin/sh /usr/bin/sh
  '';

  systemd.services."virt-secret-init-encryption".path = with pkgs; [ coreutils systemd ];
  systemd.tmpfiles.rules = [ "d /var/lib/libvirt/secrets 0700 root root -" ];
}
