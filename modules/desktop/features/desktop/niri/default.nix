{ inputs, ... }:

{
  flake.modules.homeManager.desktop-feature-niri = { pkgs, ... }:
    let
      zenFocusOrLaunch = pkgs.writeShellApplication {
        name = "zen-focus-or-launch";
        runtimeInputs = with pkgs; [ niri jq ];
        text = ''
          window_id=$(niri msg --json windows 2>/dev/null \
            | jq -r '.[] | select(.app_id == "zen-beta") | .id' \
            | head -1)
          if [ -n "$window_id" ]; then
            niri msg action focus-window --id "$window_id"
          else
            zen-beta
          fi
        '';
      };

      # xwayland-satellite makes the 1080p DP-2 the X11 primary, so Wine
      # games size themselves for it. Make the 1440p DP-1 primary. Run at
      # niri startup; retries while xwayland-satellite starts on demand.
      xwaylandPrimary = pkgs.writeShellApplication {
        name = "xwayland-primary";
        runtimeInputs = with pkgs; [ xrandr gnugrep coreutils ];
        text = ''
          for _ in $(seq 20); do
            if xrandr 2>/dev/null | grep -q '^DP-1 connected'; then
              exec xrandr --output DP-1 --primary
            fi
            sleep 0.5
          done
          echo "xwayland-primary: DP-1 not found" >&2
          exit 1
        '';
      };
    in
    {
      home.packages = [ zenFocusOrLaunch xwaylandPrimary ];

      # Linked file by file, so Nova's rules can sit beside config.kdl.
      xdg.configFile."niri" = {
        source = ./assets/niri;
        recursive = true;
      };
      # Included from config.kdl. Nova's home-manager module would link it to
      # ~/.config/nova, but Nova comes from its NixOS module here.
      xdg.configFile."niri/nova.kdl".source = "${inputs.nova-rebuild}/packaging/compositor/niri.kdl";
    };
}
