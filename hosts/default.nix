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

  # ===================================================================
  # NETWORKING
  # ===================================================================
  # Temporarily disable the IPv4 preference override.
  # environment.etc."gai.conf".text = ''
  #   precedence ::ffff:0:0/96 100
  # '';

}
