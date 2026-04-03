{ userConfig, homeProfile ? "desktop", ... }:

{
  imports = [
    userConfig
    ./workstation
    ./gaming
    ./apps
    ./desktop
  ];

  home.stateVersion = "25.11";

  home.file.".config/nixpkgs/config.nix".text = ''
    { allowUnfree = true; }
  '';

  # ── Enable / disable home modules ─────────────────────────────────────────
  modules = if homeProfile == "server" then {
    workstation.enable = false;
    gaming.enable      = false;
    apps.enable        = false;
    desktop.enable     = false;
    qupath.enable      = true;
  } else {
    workstation.enable = true;
    gaming.enable      = true;
    apps.enable        = true;
    desktop.enable     = true;
  };

  programs.home-manager.enable = true;
}
