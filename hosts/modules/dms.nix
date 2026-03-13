{ lib, config, pkgs, inputs, ... }:

let
  patchedQuickshell =
    inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.quickshell.override {
      xorg = pkgs.xorg // { libxcb = pkgs.libxcb; };
    };
in

{
  options.modules.dms.enable = lib.mkEnableOption "dank-material-shell";

  config = lib.mkIf config.modules.dms.enable {
    programs.dank-material-shell = {
      enable = true;
      quickshell.package = patchedQuickshell;
      greeter = {
        enable = true;
        compositor.name = "hyprland";
        quickshell.package = patchedQuickshell;
      };
    };
  };
}
