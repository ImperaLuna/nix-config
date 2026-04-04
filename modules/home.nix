{ userConfig, homeProfile ? "desktop", ... }:

{
  imports = [
    userConfig
  ];

  home.stateVersion = "25.11";

  home.file.".config/nixpkgs/config.nix".text = ''
    { allowUnfree = true; }
  '';

  programs.home-manager.enable = true;
}
