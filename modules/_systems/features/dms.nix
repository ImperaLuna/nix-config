{ pkgs, inputs, ... }:

let
  patchedQuickshell =
    inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.quickshell.override {
      xorg = pkgs.xorg // { libxcb = pkgs.libxcb; };
    };
in

{
  programs.dank-material-shell = {
    enable = true;
    quickshell.package = patchedQuickshell;
    greeter = {
      enable = false;
      compositor.name = "hyprland";
      quickshell.package = patchedQuickshell;
    };
  };
}
