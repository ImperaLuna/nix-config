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
    in
    {
      home.packages = [ zenFocusOrLaunch ];

      xdg.configFile."niri".source = ./assets/niri;
    };
}
