{ config, pkgs, lib, inputs, ... }:

let
  mouseRemapEnv = pkgs.python3.withPackages (ps: [ ps.evdev ]);
  mouseRemapScript = pkgs.writeText "mouse-forward-to-kp9.py" ''
    import evdev, subprocess, json, os, glob
    from evdev import ecodes, UInput, InputDevice

    TARGET_CLASS = "Albion-Online"
    HYPRCTL = "${pkgs.hyprland}/bin/hyprctl"

    def get_hyprland_env():
        sockets = glob.glob("/run/user/*/hypr/*/.socket.sock")
        if sockets:
            sig = sockets[0].split("/hypr/")[1].split("/")[0]
            uid = sockets[0].split("/run/user/")[1].split("/")[0]
            return {"HYPRLAND_INSTANCE_SIGNATURE": sig, "XDG_RUNTIME_DIR": f"/run/user/{uid}"}
        return {}

    def is_albion_focused():
        try:
            env = {**os.environ, **get_hyprland_env()}
            out = subprocess.check_output([HYPRCTL, "activewindow", "-j"], env=env)
            win = json.loads(out)
            return win.get("class", "").lower() == TARGET_CLASS.lower()
        except Exception:
            return False

    def find_mouse():
        for path in evdev.list_devices():
            dev = InputDevice(path)
            caps = dev.capabilities()
            if ecodes.EV_KEY in caps and ecodes.BTN_EXTRA in caps[ecodes.EV_KEY]:
                return dev
        return None

    mouse = find_mouse()
    if not mouse:
        print("No mouse with forward button found")
        exit(1)

    print(f"Listening on: {mouse.name} ({mouse.path})")
    ui = UInput({ecodes.EV_KEY: [ecodes.KEY_KP9]}, name="btn-forward-to-kp9")

    try:
        for event in mouse.read_loop():
            if event.type == ecodes.EV_KEY and event.code == ecodes.BTN_EXTRA:
                if is_albion_focused():
                    ui.write(ecodes.EV_KEY, ecodes.KEY_KP9, event.value)
                    ui.syn()
    except KeyboardInterrupt:
        pass
    finally:
        ui.close()
  '';

  patchedQuickshell =
    inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.quickshell.override {
      xorg = pkgs.xorg // { libxcb = pkgs.libxcb; };
    };
in

{
  imports = [
    ./hardware-configuration.nix
  ];

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

        # Direct Arch boot reference, if you want to bypass the old Limine menu later:
        # /Arch
        #   protocol: linux
        #   kernel_path: uuid(7f69578c-6084-4cb1-8888-b68a14857395):/vmlinuz-linux
        #   kernel_cmdline: root=PARTUUID=cbad4a8a-99cf-4986-a819-16a605fc58f4 zswap.enabled=0 rootflags=subvol=@ rw rootfstype=btrfs
        #   module_path: uuid(7f69578c-6084-4cb1-8888-b68a14857395):/initramfs-linux.img
      '';
    };
    efi.canTouchEfiVariables = true;
  };

  # ===================================================================
  # NETWORKING
  # ===================================================================
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
  };
# ===================================================================
  # LOCALIZATION
  # ===================================================================
  time.timeZone = "Europe/Bucharest";

  i18n = {
    defaultLocale = "en_US.UTF-8";
  };

  # ===================================================================
  # DESKTOP ENVIRONMENT / WINDOW MANAGER
  # ===================================================================
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # ===================================================================
  # SESSION ENVIRONMENT
  # ===================================================================

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
    NODE_OPTIONS = "--dns-result-order=ipv4first";
    QT_QPA_PLATFORMTHEME = "gtk3";
  };

  # ===================================================================
  # NVIDIA
  # ===================================================================

  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings = true;
    open = false;
  };

  # ===================================================================
  # USERS
  # ===================================================================
  users.users.imperaluna = {
    isNormalUser = true;
    description = "Rares Brezeanu";
    extraGroups = [ "networkmanager" "wheel" "input" "libvirtd" ];
    shell = pkgs.fish;
    packages = with pkgs; [];
  };

  # ===================================================================
  # SYSTEM CONFIGURATION
  # ===================================================================
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  nix.optimise.automatic = true;

  # ===================================================================
  # FONTS
  # ===================================================================
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  # ===================================================================
  # SYSTEM PACKAGES
  # ===================================================================
  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
    ghostty
    obsidian
    git
    grim
    discord
    bitwarden-desktop
    slurp
    zed-editor
    wl-clipboard
    python3
    steam
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
  ] ++ [
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex
  ];

  # ===================================================================
  # PROGRAMS & SERVICES
  # ===================================================================
  programs.fish.enable = true;
  programs.steam.enable = true;

  # ===================================================================
  # VIRTUALISATION
  # ===================================================================
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  system.activationScripts.usrbinsh = ''
    mkdir -p /usr/bin
    ln -sf /run/current-system/sw/bin/sh /usr/bin/sh
  '';

  systemd.services."virt-secret-init-encryption".path = with pkgs; [ coreutils systemd ];
  systemd.tmpfiles.rules = [ "d /var/lib/libvirt/secrets 0700 root root -" ];


  programs.dank-material-shell = {
    enable = true;
    quickshell.package = patchedQuickshell;
    greeter = {
      enable = true;
      compositor.name = "hyprland";
      quickshell.package = patchedQuickshell;
    };
  };

  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # services.openssh.enable = true;

  # ===================================================================
  # INPUT REMAPPING
  # ===================================================================
  boot.kernelModules = [ "uinput" ];
  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"
  '';

  systemd.services.mouse-forward-to-kp9 = {
    description = "Map mouse forward button to KP9 (Albion only)";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${mouseRemapEnv}/bin/python3 ${mouseRemapScript}";
      User = "imperaluna";
      SupplementaryGroups = "input";
      Restart = "on-failure";
      RestartSec = "2s";
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
