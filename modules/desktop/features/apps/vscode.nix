{ ... }:

{
  flake.modules.homeManager.apps-feature-vscode = { pkgs, ... }: {
    programs.vscode = {
      enable = true;
      # Electron picks its secret backend from XDG_CURRENT_DESKTOP, and niri
      # is unrecognised, so point it at the GNOME keyring for sign-ins.
      package = pkgs.vscode.override {
        commandLineArgs = "--password-store=gnome-libsecret";
      };
    };
  };
}
