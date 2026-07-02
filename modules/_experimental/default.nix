{ ... }:

{
  # Temporary/experimental packages live here.
  # Keep entries commented by default and enable only while testing.
  flake.modules.homeManager.experimental = { pkgs, ... }: {
    imports = [
      ./noctalia.nix
    ];

    home.packages = [
      # pkgs.alacritty
      pkgs.google-chrome

      # (pkgs.callPackage ./pkgs/qupath.nix { })
    ];
  };
}
