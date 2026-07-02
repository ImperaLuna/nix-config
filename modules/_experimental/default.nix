{ inputs, ... }:

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
      inputs.dank-material-shell.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.caelestia-shell.packages.${pkgs.stdenv.hostPlatform.system}.with-cli

      # (pkgs.callPackage ./pkgs/qupath.nix { })
    ];
  };
}
