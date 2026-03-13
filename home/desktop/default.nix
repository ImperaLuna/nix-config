{ lib, config, pkgs, ... }:

{
  options.modules.desktop.enable = lib.mkEnableOption "desktop environment config";

  config = lib.mkIf config.modules.desktop.enable {
    home.packages = with pkgs; [
      libqalculate                              # qalc CLI for calculator plugin
      kdePackages.kdeconnect-kde                 # phone connect plugin
      (pkgs.callPackage ./pkgs/codexbar.nix {}) # codexbar CLI for CodexBar plugin
    ];

    xdg.configFile."hypr".source = ./assets/hypr;
    xdg.configFile."quickshell".source = ./assets/quickshell;
    xdg.configFile."DankMaterialShell".source =
      config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/nix-config/home/desktop/assets/DankMaterialShell";
  };
}
