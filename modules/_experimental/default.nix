{ ... }:

{
  # Temporary/experimental packages live here.
  # Keep entries commented by default and enable only while testing.
  flake.modules.homeManager.experimental = { pkgs, ... }:
    let
      t3code = pkgs.callPackage ./pkgs/t3code.nix { };
    in
    {
      home.packages = [
        t3code
        # pkgs.alacritty
        # pkgs.google-chrome
      ];
    };
}
