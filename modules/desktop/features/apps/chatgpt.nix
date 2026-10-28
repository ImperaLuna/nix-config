{ inputs, ... }:

{
  flake.modules.homeManager.apps-feature-chatgpt = { pkgs, ... }:
  let
    agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  in
  {
    home.packages = [
      # niri needs an explicit secret backend so Electron can save sign-in.
      (agents.chatgpt.override {
        commandLineArgs = "--password-store=gnome-libsecret";
      })
    ];
  };
}
