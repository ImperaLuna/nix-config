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
    # At most 2 builds at once, 6 threads each, so 12 compiler threads on a
    # 12-thread CPU. Nova CI's NixOS VM tests take up to 3 GB each, and 4 of
    # them next to a 17 GB desktop pushed the machine into swap.
    max-jobs = 2;
    cores = 6;
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
    # Fixed sizes, not percentages: the desktop alone often holds 17 GB of
    # the 31 GB. Past 10G the kernel reclaims build memory and slows the
    # builds down. At 13G the build gets OOM-killed instead of freezing the
    # desktop.
    MemoryHigh = "10G";
    MemoryMax = "13G";
    # Stop builds from pushing the desktop's memory out to swap.
    MemorySwapMax = "4G";
    CPUWeight = 20;
    IOWeight = 20;
  };

  # Compressed swap in RAM, used before the disk swap partition (higher
  # priority), so swapping under memory pressure doesn't stall on the NVMe.
  zramSwap = {
    enable = true;
    memoryPercent = 50;
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
