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
    extra-substituters = [ "https://cache.numtide.com" ];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
    max-jobs = "auto";
    cores = 0;
    keep-outputs = true;
    keep-derivations = true;
  };
  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
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
  programs.fish.enable = true;
  environment.systemPackages = with pkgs; [
    bind
    iputils
    iw
    ndisc6
    tcpdump
  ];

}
