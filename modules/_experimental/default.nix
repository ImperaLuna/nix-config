{ ... }:

{
  # Temporary/experimental packages live here.
  # Keep entries commented by default and enable only while testing.
  flake.modules.homeManager.experimental = { pkgs, ... }:
    let
      t3code = pkgs.callPackage ./pkgs/t3code.nix { };
    in
    {
      home.packages = [
        pkgs.gemini-cli
        t3code
        # pkgs.alacritty
        # pkgs.google-chrome
      ];

      programs.tmux = {
        enable = true;
        historyLimit = 100000;
        mouse = true;
      };
    };
}
