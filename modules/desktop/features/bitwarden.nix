{ ... }:

{
  flake.modules.homeManager.desktop-feature-bitwarden = { pkgs, ... }: {
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
