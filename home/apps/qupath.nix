{ lib, config, pkgs, ... }:

{
  options.modules.qupath.enable = lib.mkEnableOption "qupath";

  config = lib.mkIf config.modules.qupath.enable {
    home.packages = [
      (pkgs.callPackage ./pkgs/qupath.nix {})
    ];
  };
}
