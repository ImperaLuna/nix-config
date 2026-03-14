{ lib, config, inputs, pkgs, ... }:

{
  options.modules.zen.enable = lib.mkEnableOption "zen browser";

  config = lib.mkIf config.modules.zen.enable {
    home.packages = [
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    xdg.desktopEntries."zen-beta" = {
      name = "Zen Browser (Beta)";
      exec = "zen-beta --name zen-beta %U";
      icon = "zen-browser";
      categories = [ "Network" "WebBrowser" ];
      mimeType = [ "text/html" "text/xml" "application/xhtml+xml" "x-scheme-handler/http" "x-scheme-handler/https" ];
      startupNotify = true;
      settings.StartupWMClass = "zen-beta";
    };
  };
}
