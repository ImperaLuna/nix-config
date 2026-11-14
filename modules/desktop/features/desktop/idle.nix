{ ... }:

{
  # Turn every screen off after 15 minutes idle, to spare the OLED panel.
  # Video players and games that hold an idle inhibitor keep them on.
  flake.modules.homeManager.desktop-feature-idle = { pkgs, ... }:
    let
      # hypridle runs under both compositors. Hyprland's Lua config takes
      # dispatchers as Lua calls; niri wakes the screens on any input by itself.
      screens = pkgs.writeShellScript "screens" ''
        case "$XDG_CURRENT_DESKTOP" in
          Hyprland) hyprctl dispatch "hl.dsp.dpms({ action = \"$1\" })" ;;
          niri) [ "$1" = off ] && niri msg action power-off-monitors ;;
        esac
      '';
    in
    {
      services.hypridle = {
        enable = true;
        settings.listener = [
          {
            timeout = 900;
            on-timeout = "${screens} off";
            on-resume = "${screens} on";
          }
        ];
      };
    };
}
