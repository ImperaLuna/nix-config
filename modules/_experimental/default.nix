{ ... }:

{
  # Temporary/experimental packages live here.
  # Keep entries commented by default and enable only while testing.
  flake.modules.homeManager.experimental = { pkgs, ... }:
    {
      home.packages = [
        pkgs.t3code
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
