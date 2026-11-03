{ inputs, ... }:

{
  flake.modules.homeManager.desktop-feature-zen = { pkgs, ... }: {
    home.packages = [
      (inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
        # Open and Save dialogs (uploads, downloads) go through
        # xdg-desktop-portal, which hands them to Nova Files. Unset, Zen
        # only uses the portal inside Flatpak or Snap.
        extraPolicies.Preferences."widget.use-xdg-desktop-portal.file-picker" = {
          Value = 1;
          Status = "default";
        };
      })
    ];

    xdg = {
      desktopEntries."zen-beta" = {
        name = "Zen Browser (Beta)";
        exec = "zen-beta --name zen-beta %U";
        icon = "zen-browser";
        categories = [ "Network" "WebBrowser" ];
        mimeType = [ "text/html" "text/xml" "application/xhtml+xml" "x-scheme-handler/http" "x-scheme-handler/https" ];
        startupNotify = true;
        settings.StartupWMClass = "zen-beta";
      };

      mimeApps = {
        enable = true;
        defaultApplications = {
          "text/html" = [ "zen-beta.desktop" ];
          "application/xhtml+xml" = [ "zen-beta.desktop" ];
          "x-scheme-handler/http" = [ "zen-beta.desktop" ];
          "x-scheme-handler/https" = [ "zen-beta.desktop" ];
        };
      };
    };
  };
}
