{ pkgs, ... }:

{
  flake.modules.homeManager.experimental = {
    home.packages = with pkgs; [
      # temporary/experimental packages live here
      # alacritty
    ];
  };
}
