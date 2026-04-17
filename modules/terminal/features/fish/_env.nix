{ lib, ... }:

{
  programs.fish.shellInit = lib.mkBefore ''
    set -gx EDITOR zeditor
    set -gx VISUAL zeditor

  '';
}
