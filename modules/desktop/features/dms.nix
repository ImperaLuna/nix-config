{ ... }:

{
  flake.modules.homeManager.desktop-feature-dms = { config, pkgs, ... }: {
    home.packages = with pkgs; [
      cosmic-files
      libqalculate
      kdePackages.kdeconnect-kde
      (pkgs.callPackage ../pkgs/codexbar.nix { })
    ];

    xdg.configFile."quickshell".source = ../assets/quickshell;
    xdg.configFile."DankMaterialShell".source =
      config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/nix-config/modules/desktop/assets/DankMaterialShell";
  };
}
