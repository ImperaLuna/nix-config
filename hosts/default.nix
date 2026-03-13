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

  # Disable IPv6 at kernel level
  boot.kernel.sysctl = {
    "net.ipv6.conf.all.disable_ipv6" = 1;
    "net.ipv6.conf.default.disable_ipv6" = 1;
    "net.ipv6.conf.lo.disable_ipv6" = 1;
  };
}
