{ lib, config, pkgs, ... }:

{
  options.modules.bitwarden.enable = lib.mkEnableOption "bitwarden";

  config = lib.mkIf config.modules.bitwarden.enable {
    home.packages = [ pkgs.bitwarden-desktop ];

    xdg.desktopEntries.bitwarden = {
      name = "Bitwarden";
      comment = "Secure and free password manager for all of your devices";
      exec = "bitwarden %U";
      icon = "bitwarden";
      categories = [ "Utility" ];
      mimeType = [ "x-scheme-handler/bitwarden" ];
    };
  };
}
