{ ... }:

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

      screenshotArea = pkgs.writeShellApplication {
        name = "niri-screenshot-area-instant";
        runtimeInputs = with pkgs; [
          grim
          libnotify
          slurp
          util-linux
          wl-clipboard
        ];
        text = ''
          # Prevent multiple selection overlays from stacking.
          exec 9>/tmp/screenshot-area.lock
          flock -n 9 || exit 0
          trap 'rm -f /tmp/screenshot-area.lock' EXIT

          screens_dir="''${HOME}/Pictures/Screenshots"
          timestamp="$(date +%Y-%m-%d_%H-%M-%S)"
          outfile="''${screens_dir}/screenshot-''${timestamp}.png"

          mkdir -p "''${screens_dir}"

          geometry="$(slurp)"
          [ -n "''${geometry}" ]

          grim -g "''${geometry}" "''${outfile}"
          wl-copy < "''${outfile}"
          notify-send -a "Screenshot" -i "''${outfile}" "Screenshot saved" "$(basename "''${outfile}") copied to clipboard" || true
        '';
      };
    in
    {
      home.packages = with pkgs; [
        zenFocusOrLaunch
        screenshotArea
        swaybg
      ];

      xdg.configFile."niri".source = ./assets/niri;
    };
}
