{ pkgs, ... }:

{
  flake.modules.homeManager.experimental-default = {
    home.packages = with pkgs; [
      # temporary/experimental packages live here
      alacritty
    ];
  };
}
