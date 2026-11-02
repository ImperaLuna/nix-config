{ ... }:

{
  # Temporary/experimental packages live here.
  # Keep entries commented by default and enable only while testing.
  flake.modules.homeManager.experimental = { pkgs, ... }:
    {
      home.packages = [
        # pkgs.alacritty
        # pkgs.google-chrome

        # Root chat app, upstream AppImage. See root.md.
        (pkgs.callPackage ./root.nix { })
      ];

    };
}
