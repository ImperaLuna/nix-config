{ userConfig, ... }:

{
  imports = [
    userConfig
    ./terminal
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
  modules = {
    terminal.enable    = true;
    workstation.enable = true;
    gaming.enable      = true;
    apps.enable        = true;
    desktop.enable     = true;
  };

  programs.home-manager.enable = true;
}
