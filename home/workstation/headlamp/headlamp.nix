{ lib, config, pkgs, ... }:

{
  options.modules.headlamp.enable = lib.mkEnableOption "headlamp";

  config = lib.mkIf config.modules.headlamp.enable {
    home.packages = [
      (pkgs.callPackage ./pkgs/headlamp.nix {})
    ];
  };
}
