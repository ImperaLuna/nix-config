{ inputs, ... }:

{
  flake.modules.homeManager.apps-feature-claude-desktop = { pkgs, ... }:
  let
    # Built from Anthropic's official Linux .deb; not in nixpkgs.
    agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  in
  {
    home.packages = [
      # Electron picks its secret backend from XDG_CURRENT_DESKTOP, and niri
      # is unrecognised, so it stores no sign-in without being told.
      (agents.claude-desktop.override {
        commandLineArgs = "--password-store=gnome-libsecret";
      })
    ];
  };
}
