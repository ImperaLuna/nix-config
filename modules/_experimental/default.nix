{ ... }:

{
  # Temporary/experimental packages live here.
  # Keep entries commented by default and enable only while testing.
  flake.modules.homeManager.experimental = { pkgs, ... }: {
    home.packages = [
      # pkgs.alacritty

      # (pkgs.callPackage ./pkgs/qupath.nix { })
    ];

  };
}
