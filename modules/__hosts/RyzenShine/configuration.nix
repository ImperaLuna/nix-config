{ pkgs, inputs, config, ... }:

let
  sddmSessionDir = pkgs.runCommand "sddm-sessions" { } ''
    mkdir -p "$out/share/wayland-sessions" "$out/share/xsessions"
    cp -RL ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions/. "$out/share/wayland-sessions/"
    cp -RL ${config.services.displayManager.sessionData.desktops}/share/xsessions/. "$out/share/xsessions/"
    rm -f "$out/share/wayland-sessions/hyprland.desktop"
  '';

  # Keep in sync with the lock screen theme in modules/desktop/features/desktop/qylock.
  qylockTheme = "pixel-dusk-city";

  qylockSddmTheme = pkgs.stdenvNoCC.mkDerivation {
    pname = "qylock-sddm-theme";
    version = "unstable-2026-04-09";
    src = inputs.qylock;
    dontBuild = true;

    installPhase = ''
      mkdir -p "$out/share/sddm/themes/qylock"
      cp -r themes/${qylockTheme}/* "$out/share/sddm/themes/qylock/"
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

  programs.nh.flake = "/home/imperaluna/nix-config";

  # Let agents apply this repo, roll back, clean the store and restart units
  # without a password. Arguments are pinned so only these exact forms match.
  security.sudo.extraRules = [{
    users = [ "imperaluna" ];
    commands = map (command: { inherit command; options = [ "NOPASSWD" ]; }) [
      "/run/current-system/sw/bin/nixos-rebuild switch --flake /home/imperaluna/nix-config"
      "/run/current-system/sw/bin/nixos-rebuild switch --rollback"
      "/run/current-system/sw/bin/nh clean all --keep-since 7d --keep 3"
      "/run/current-system/sw/bin/systemctl restart *"
      "/run/current-system/sw/bin/systemctl reset-failed *"
    ];
  }];

  # The Claude desktop app runs in a bwrap FHS env that sets no_new_privs,
  # so sudo can't work from it. These units run the same commands as root,
  # and polkit lets imperaluna start only them, with `systemctl start`.
  # Output goes to the journal and to /var/log/<unit>.log, because bwrap
  # also drops the wheel group that grants journal access.
  systemd.services = builtins.mapAttrs (name: args: {
    description = "nixos-rebuild ${args}";
    path = [ config.nix.package pkgs.git ];
    serviceConfig.Type = "oneshot";
    script = ''
      set -o pipefail
      # libgit2 refuses a repo root doesn't own, unless SUDO_UID names the
      # owner. sudo sets it, so do the same here. Pinned to imperaluna's
      # uid so the unit fails if the repo ever changes owner.
      export SUDO_UID=1000
      ${config.system.build.nixos-rebuild}/bin/nixos-rebuild ${args} 2>&1 | tee /var/log/${name}.log
    '';
    # Switching would otherwise restart the unit that is doing the switch.
    restartIfChanged = false;
    stopIfChanged = false;
  }) {
    nixos-apply = "switch --flake /home/imperaluna/nix-config";
    nixos-rollback = "switch --rollback";
  };

  security.polkit.extraConfig = ''
    polkit.addRule(function (action, subject) {
      if (action.id == "org.freedesktop.systemd1.manage-units" &&
          subject.user == "imperaluna" &&
          action.lookup("verb") == "start" &&
          ["nixos-apply.service", "nixos-rollback.service"].indexOf(action.lookup("unit")) >= 0) {
        return polkit.Result.YES;
      }
    });
  '';

  programs.steam.enable = true;
  # Nova's screen recording (NVENC); the module adds the KMS capture helper.
  programs.gpu-screen-recorder.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;
  security.pam.services.login.enableGnomeKeyring = true;
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # ===================================================================
  # PERIPHERALS
  # ===================================================================
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
    shell = pkgs.zsh;
    # Start user services at boot, before login (claude-remote-control).
    linger = true;
  };

  # ===================================================================
  # BOOT
  # ===================================================================
  boot.loader = {
    timeout = 60;
    systemd-boot.enable = false;
    limine = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = true;
      maxGenerations = 5;
      # Windows EFI partition on the SK hynix SSD.
      extraEntries = ''
        /Windows 11
          protocol: efi
          path: uuid(7f69578c-6084-4cb1-8888-b68a14857395):/EFI/Microsoft/Boot/bootmgfw.efi
      '';
    };
  };

  # DELAY_INIT quirk for SteelSeries Arctis Nova 5X (1038:2253) — 6.18.x regression
  # where the USB audio control interface times out during enumeration.
  boot.kernelParams = [ "usbcore.quirks=1038:2253:0x40" ];
  boot.extraModprobeConfig = "options kvm_amd nested=1";

  # ===================================================================
  # GPU — nvidia proprietary driver
  # ===================================================================
  services.xserver.videoDrivers = [ "nvidia" ];
  # Niri is the daily session. sddmSessionDir above hides the plain
  # Hyprland entry so only the recommended UWSM one is offered.
  services.displayManager.defaultSession = "niri";
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "${qylockSddmTheme}/share/sddm/themes/qylock";
    settings = {
      # The theme's video background goes blank when Qt hands VA-API frames
      # to the GPU ("vaExportSurfaceHandle failed" on nvidia-vaapi-driver).
      # Decode in software and upload frames from CPU memory instead.
      General.GreeterEnvironment = "QT_FFMPEG_DECODING_HW_DEVICE_TYPES=none,QT_DISABLE_HW_TEXTURES_CONVERSION=1";
      Wayland.SessionDir = "${sddmSessionDir}/share/wayland-sessions";
      X11.SessionDir = "${sddmSessionDir}/share/xsessions";
    };
    extraPackages = with pkgs.qt6; [
      qt5compat
      qtdeclarative
      qtmultimedia
      qtsvg
    ];
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    nvidiaSettings = false;
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # GPU acceleration + 32-bit support (required for Steam/games)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # ===================================================================
  # AUDIO
  # ===================================================================
  # Udev rules for USB peripherals.
  services.udev.extraRules = ''
    # Allow Keychron Launcher/Chrome WebHID to open the K2 HE wired and 2.4 GHz receiver hidraw interfaces.
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0e20", MODE="0660", GROUP="users", TAG+="uaccess"
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="d030", MODE="0660", GROUP="users", TAG+="uaccess"

    # Disable USB autosuspend for the SteelSeries Arctis Nova 5X dongle to
    # prevent the 2-3 second audio dropout caused by the kernel suspending the
    # USB device and it re-enumerating.
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="1038", ATTR{idProduct}=="2253", ATTR{power/autosuspend}="-1"
  '';

  # headsetcontrol sets the Nova 5X auto-off timer (headsetcontrol -i 0 = never).
  # Its udev rules give the logged-in user access to the dongle's hidraw device.
  environment.systemPackages = [ pkgs.headsetcontrol ];
  services.udev.packages = [ pkgs.headsetcontrol ];

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
    OBSIDIAN_VAULT = "/home/imperaluna/Obsidian/Rares's Vault";
    TERMINAL = "ghostty";          # launcher uses this for Terminal=true desktop entries
    WLR_NO_HARDWARE_CURSORS = "1";  # fixes invisible cursor on nvidia+wayland
    NIXOS_OZONE_WL = "1";           # native wayland for electron apps
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
