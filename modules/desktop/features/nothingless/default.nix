{ ... }:

{
  flake.modules.homeManager.desktop-feature-nothingless = { pkgs, ... }:
    let
      nothingless = import ./_pkgs/default.nix { inherit pkgs; };
    in
    {
      home.packages = [
        nothingless
      ];

      home.file.".local/bin/nothingless".source = "${nothingless}/bin/nothingless";
    };
}
