{ inputs, ... }:

{
  # Temporary/experimental packages live here.
  # Keep entries commented by default and enable only while testing.
  flake.modules.homeManager.experimental = { pkgs, ... }:
    {
      home.packages = [
        # pkgs.alacritty
        # pkgs.google-chrome

        # Nova Files is installed system-wide by programs.nova-files on RyzenShine.

        # Trying Dolphin and Thunar for comparison.
        # pkgs.kdePackages.dolphin
        # pkgs.thunar
      ];

    };
}
