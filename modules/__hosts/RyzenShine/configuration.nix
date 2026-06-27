{ pkgs, inputs, config, ... }:

let
  qylockSddmTheme = pkgs.stdenvNoCC.mkDerivation {
    pname = "qylock-sddm-theme";
    version = "unstable-2026-04-09";
    src = inputs.qylock;
    dontBuild = true;

    installPhase = ''
      mkdir -p "$out/share/sddm/themes/qylock"
      cp -r themes/pixel-dusk-city/* "$out/share/sddm/themes/qylock/"
      chmod -R u+w "$out/share/sddm/themes/qylock"
      substituteInPlace "$out/share/sddm/themes/qylock/Main.qml" \
        --replace-fail 'property string uName:  model.realName || model.name || ""' \
                       'property string uName:  model.name || ""'
    '';
  };
in
{
  imports = [
    ../common.nix
  ];

  programs.steam.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;
  security.pam.services.login.enableGnomeKeyring = true;
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
  # PERIPHERALS
  # ===================================================================
  services.printing.enable = true; # Turns on printer support (so adding/using printers works)
  services.ipp-usb.enable = true; # Makes many USB printers/scanners show up automatically
  hardware.sane.enable = true; # Turns on scanner support
  services.fwupd.enable = true; # Lets you update firmware for devices (BIOS/docks/etc.)
  services.udisks2.enable = true; # Lets file managers mount/unmount USB drives
  services.gvfs.enable = true; # Makes external/network drives show up nicely in GUI apps

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
      # Machine-specific dual-boot convenience entry for this desktop.
      # Replace or remove on new hosts because EFI partition UUID/path will differ.
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

  # DELAY_INIT quirk for SteelSeries Arctis Nova 5X (1038:2253) — 6.18.x regression
  # where the USB audio control interface times out during enumeration.
  boot.kernelParams = [ "usbcore.quirks=1038:2253:0x40" ];

  # ===================================================================
  # GPU — nvidia proprietary driver
  # ===================================================================
  services.xserver.videoDrivers = [ "nvidia" ];
  services.displayManager.defaultSession = "hyprland-uwsm";
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "${qylockSddmTheme}/share/sddm/themes/qylock";
    extraPackages = with pkgs.qt6; [
      qt5compat
      qtdeclarative
      qtmultimedia
      qtsvg
    ];
  };

  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings = false;
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.dc_590;
  };

  # GPU acceleration + 32-bit support (required for Steam/games)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # ===================================================================
  # AUDIO
  # ===================================================================
  # Disable USB autosuspend for the SteelSeries Arctis Nova 5X dongle to
  # prevent the 2-3 second audio dropout caused by the kernel suspending the
  # USB device and it re-enumerating.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="1038", ATTR{idProduct}=="2253", ATTR{power/autosuspend}="-1"
  '';

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
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

  environment.systemPackages = [
    qylockSddmTheme
  ];

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
