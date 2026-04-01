{ pkgs, ... }:

{
  imports = [
    ../default.nix
    ./hardware-configuration.nix
    ../modules/remote-access.nix
    ../modules/homelab.nix
  ];

  modules.remote-access.enable = true;
  modules.homelab.enable = true;

  # ===================================================================
  # NETWORKING
  # ===================================================================
  networking = {
    hostName = "DuskNova";
    networkmanager.enable = true;
    interfaces.wlp2s0 = {
      useDHCP = false;
      ipv4.addresses = [{
        address = "192.168.68.109";
        prefixLength = 24;
      }];
    };
    defaultGateway = "192.168.68.1";
    nameservers = [ "192.168.68.1" ];
  };

  # ===================================================================
  # USERS
  # ===================================================================
  users.users.imperaluna = {
    isNormalUser = true;
    description = "Rares Brezeanu";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.fish;
  };

  # ===================================================================
  # BOOT
  # ===================================================================
  boot.loader = {
    timeout = 5;
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = false;
    limine = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = true;
      maxGenerations = 5;
      extraEntries = ''
        /Arch Limine
          protocol: efi
          path: uuid(7f69578c-6084-4cb1-8888-b68a14857395):/EFI/limine/limine_x64.efi

        # Example bypass Limine menu:
        # /Arch
        #   protocol: linux
        #   kernel_path: uuid(7f69578c-6084-4cb1-8888-b68a14857395):/vmlinuz-linux
        #   kernel_cmdline: root=PARTUUID=cbad4a8a-99cf-4986-a819-16a605fc58f4 zswap.enabled=0 rootflags=subvol=@ rw rootfstype=btrfs
        #   module_path: uuid(7f69578c-6084-4cb1-8888-b68a14857395):/initramfs-linux.img
      '';
    };
  };

  # ===================================================================
  # FIREWALL
  # ===================================================================
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # networking.firewall.enable = false;

  # ===================================================================
  # STATE VERSION - DO NOT CHANGE
  # ===================================================================
  system.stateVersion = "25.11";
}
