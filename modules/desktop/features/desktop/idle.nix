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
      # ~/.config/hypr is one store symlink, so Home Manager can't add
      # hypridle.conf inside it. Hand hypridle a store file instead.
      config = pkgs.writeText "hypridle.conf" ''
        listener {
          timeout = 900
          on-timeout = ${screens} off
          on-resume = ${screens} on
        }
      '';
    in
    {
      services.hypridle.enable = true;
      systemd.user.services.hypridle.Service.ExecStart =
        pkgs.lib.mkForce "${pkgs.hypridle}/bin/hypridle -c ${config}";
    };
}
