{ inputs, ... }:

{
  # Temporary/experimental packages live here.
  # Keep entries commented by default and enable only while testing.
  flake.modules.homeManager.experimental = { pkgs, ... }:
    {
      home.packages = [
        # pkgs.alacritty
        # pkgs.google-chrome

        # Trying COSMIC Files as a GUI file manager.
        pkgs.cosmic-files

        # Trying Flea, the Omarchy file manager, in an FHS env.
        (pkgs.callPackage ./flea/package.nix { })

        # Trying Nova Files, the GPUI file manager.
        inputs.nova-files.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];

    };
}
