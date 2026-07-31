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
        t3code
        # pkgs.alacritty
        # pkgs.google-chrome
      ];

      # Temporary tray-only bar for testing Black Desert's Wine/XWayland tray
      # restore behavior independently of Nova. Start it manually with `waybar`.
      programs.waybar = {
        enable = true;
        settings.tray-test = {
          layer = "overlay";
          position = "top";
          height = 36;
          exclusive = false;
          modules-right = [ "tray" ];
          tray = {
            icon-size = 22;
            spacing = 8;
          };
        };
        style = ''
          window#waybar {
            background: transparent;
          }

          #tray {
            margin: 4px 8px;
            padding: 3px 8px;
            border-radius: 999px;
            background: rgba(30, 30, 46, 0.95);
          }
        '';
      };
    };
}
