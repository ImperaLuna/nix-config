{ pkgs, ... }:

{
  # ===================================================================
  # LOCALIZATION
  # ===================================================================
  time.timeZone = "Europe/Bucharest";

  i18n = {
    defaultLocale = "en_US.UTF-8";
  };

  # ===================================================================
  # SYSTEM CONFIGURATION
  # ===================================================================
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.nvidia.acceptLicense = true;
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    extra-substituters = [
      "https://cache.numtide.com"
      "https://nova-de.cachix.org"
    ];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "nova-de.cachix.org-1:PSKB85+3Z9v+SpwEymGAclH5gYWjiqOWHFgXJicy4FQ="
    ];
    # At most 4 builds at once, 4 threads each: 16 compiler threads on a
    # 12-thread CPU. The old auto/0 allowed 12 builds x 12 threads, which
    # filled RAM and swap during big upgrades.
    max-jobs = 4;
    cores = 4;
    # Collect garbage during builds when free space runs low, between weekly cleans.
    min-free = 10 * 1024 * 1024 * 1024;
    max-free = 50 * 1024 * 1024 * 1024;
  };
  nix.optimise.automatic = true;

  # Keep the desktop usable while nix builds, rebuilds or upgrades. Builds,
  # CI included, run inside nix-daemon, so these limits cover all of them.
  # SCHED_IDLE: builds only get CPU time nothing else wants.
  nix.daemonCPUSchedPolicy = "idle";
  nix.daemonIOSchedClass = "idle";
  systemd.services.nix-daemon.serviceConfig = {
    # Past 60% of RAM the kernel reclaims build memory and slows the builds
    # down. At 75% the build gets OOM-killed instead of freezing the desktop.
    MemoryHigh = "60%";
    MemoryMax = "75%";
    # Stop builds from pushing the desktop's memory out to swap.
    MemorySwapMax = "4G";
    CPUWeight = 20;
    IOWeight = 20;
  };

  # nh clean also prunes per-user profiles under ~/.local/state/nix/profiles,
  # which nix.gc never sees. --keep 3 keeps a rollback after long breaks.
  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep-since 7d --keep 3";
    };
  };

  # ===================================================================
  # FONTS
  # ===================================================================
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    open-sans
    noto-fonts
    noto-fonts-color-emoji
  ];

  # ===================================================================
  # KEYBOARD
  # ===================================================================
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # ===================================================================
  # PROGRAMS
  # ===================================================================
  programs.zsh.enable = true;
  environment.systemPackages = with pkgs; [
    bind
    iputils
    iw
    ndisc6
    tcpdump
  ];

}
