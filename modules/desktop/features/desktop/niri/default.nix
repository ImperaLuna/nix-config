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
      # games size themselves for it. Keep the 1440p DP-1 primary. Run at
      # niri startup and keep watching: when DP-1 disconnects and returns
      # (monitor sleep), satellite loses track of it and leaves DP-2
      # primary until it restarts.
      xwaylandPrimary = pkgs.writeShellApplication {
        name = "xwayland-primary";
        runtimeInputs = with pkgs; [ xrandr gnugrep coreutils ];
        text = ''
          while true; do
            monitors=$(xrandr --listmonitors 2>/dev/null || true)
            if grep -q ' DP-1$' <<<"$monitors" \
              && ! grep -q '^ *[0-9]*: +\*DP-1 ' <<<"$monitors"; then
              xrandr --output DP-1 --primary 2>/dev/null || true
            fi
            sleep 2
          done
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
