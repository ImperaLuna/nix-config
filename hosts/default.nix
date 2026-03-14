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

  # ===================================================================
  # NETWORKING
  # ===================================================================
  # Prefer IPv4 over IPv6 for getaddrinfo (fixes apps that don't handle IPv6 well)
  environment.etc."gai.conf".text = ''
    precedence ::ffff:0:0/96 100
  '';

}
