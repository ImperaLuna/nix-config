{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ../default.nix
    ../modules/hyprland.nix
    ./hardware-configuration.nix
    ../modules/input-remap.nix
    ../modules/virtualisation.nix
    ../modules/dms.nix
  ];

  modules.input-remap.enable = true;
  modules.hyprland.enable = true;
  modules.virtualisation.enable = true;
  modules.dms.enable = true;

  programs.steam.enable = true;
  programs.kdeconnect.enable = true;
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
    };
  };
  # ===================================================================
  # NETWORKING
  # ===================================================================
  networking = {
    hostName = "RyzenShine";
    networkmanager.enable = true;
  };

  # ===================================================================
  # USERS
  # ===================================================================
  users.users.imperaluna = {
    isNormalUser = true;
    description = "Rares Brezeanu";
    extraGroups = [ "networkmanager" "wheel" "input" "libvirtd" ];
    shell = pkgs.fish;
  };

  # ===================================================================
  # BOOT
  # ===================================================================
  boot.loader = {
    timeout = 5;
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
  # GPU — nvidia proprietary driver
  # ===================================================================
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings = true;
    open = false;
  };

  # GPU acceleration + 32-bit support (required for Steam/games)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # ===================================================================
  # SESSION ENVIRONMENT
  # ===================================================================
  environment.sessionVariables = {
    TERMINAL = "ghostty";          # launcher uses this for Terminal=true desktop entries
    WLR_NO_HARDWARE_CURSORS = "1";  # fixes invisible cursor on nvidia+wayland
    NIXOS_OZONE_WL = "1";           # native wayland for electron apps
    QT_QPA_PLATFORMTHEME = "gtk3";  # Qt apps use GTK theme
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
