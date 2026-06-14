{ pkgs, ... }:

let
  nothinglessSupport = import ../../desktop/features/nothingless/_pkgs/support.nix { inherit pkgs; };
in
{
  fonts.packages = with pkgs; [
    roboto
    roboto-mono
    nerd-fonts.symbols-only
    nothinglessSupport.phosphorIcons
  ];

  programs.gpu-screen-recorder.enable = true;
}
