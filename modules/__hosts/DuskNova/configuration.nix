{ lib, pkgs, ... }:

let
  # If AC is missing, schedule a wake in 10 minutes and power off.
  # This creates a "retry loop" while power is out: boot -> check AC -> off -> wake.
  powerFailGuard = pkgs.writeShellScript "power-fail-guard" ''
    set -euo pipefail

    # Prevent overlapping runs if boot and udev trigger near the same time.
    exec 9>/run/power-fail-guard.lock
    flock -n 9 || exit 0

    # Return one of: online, offline, unknown.
    ac_state() {
      local ps type online found_mains=0
      for ps in /sys/class/power_supply/*; do
        [ -d "$ps" ] || continue
        [ -r "$ps/type" ] || continue
        type="$(cat "$ps/type" 2>/dev/null || true)"
        if [ "$type" = "Mains" ]; then
          found_mains=1
          online="$(cat "$ps/online" 2>/dev/null || true)"
          if [ "$online" = "1" ]; then
            echo online
            return 0
          fi
        fi
      done

      if [ "$found_mains" -eq 1 ]; then
        echo offline
        return 0
      fi

      # Fallback if no sysfs Mains device is visible yet.
      if on_ac_power >/dev/null 2>&1; then
        rc=0
      else
        rc=$?
      fi
      case "$rc" in
        0) echo online ;;
        1) echo offline ;;
        *) echo unknown ;;
      esac
    }

    # Debounce power detection to avoid false shutdown on boot/device churn.
    # Require all samples to report "offline" before powering off.
    samples=8
    interval=3
    i=1
    while [ "$i" -le "$samples" ]; do
      state="$(ac_state)"
      case "$state" in
        online)
          logger -t power-fail-guard "AC online (sample $i/$samples), leaving system running"
          exit 0
          ;;
        unknown)
          logger -t power-fail-guard "AC state unknown (sample $i/$samples), skipping shutdown"
          exit 0
          ;;
      esac
      sleep "$interval"
      i=$((i + 1))
    done

    logger -t power-fail-guard "AC offline across $samples samples, scheduling RTC wake in 600s then powering off"
    exec rtcwake -m off -s 600
  '';
in
{
  imports = [
    ../common.nix
    ../../../hosts/modules/remote-access.nix
    ../../../hosts/modules/homelab.nix
  ];

  modules.remote-access.enable = true;
  modules.homelab.enable = true;

  # ===================================================================
  # NETWORKING
  # ===================================================================
  networking = {
    hostName = "DuskNova";
    networkmanager.enable = true;
    enableIPv6 = false;
    wireless.enable = lib.mkForce false;
  };

  # Force IPv4 preference so apps don't try IPv6 first and time out
  environment.etc."gai.conf".text = ''
    precedence ::ffff:0:0/96  100
  '';

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 0;
  };
  boot.kernelParams = [ "consoleblank=300" ];
  boot.tmp.cleanOnBoot = true;

  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
  };

  hardware.bluetooth.enable = false;
  powerManagement.cpuFreqGovernor = "schedutil";

  services.fstrim.enable = true;
  services.upower.enable = true;
  services.upower.criticalPowerAction = "PowerOff";

  systemd.settings.Manager.RuntimeWatchdogSec = "30s";

  environment.systemPackages = with pkgs; [
    acpi # on_ac_power
    util-linux # rtcwake + flock
  ];

  # Run on every boot so the machine auto-shuts down quickly if it came up on battery.
  systemd.services.power-fail-guard = {
    description = "Shutdown on battery, retry wake every 10 minutes";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = powerFailGuard;
    };
    path = [ pkgs.acpi pkgs.util-linux ];
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
  };

  services.udev.extraRules = ''
    # Also react immediately when AC is unplugged while the laptop is running.
    SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", TAG+="systemd", ENV{SYSTEMD_WANTS}+="power-fail-guard.service"
  '';

  # ===================================================================
  # USERS
  # ===================================================================
  users.users.dusknova = {
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
