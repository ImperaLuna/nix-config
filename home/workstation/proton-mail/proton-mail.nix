{ lib, config, pkgs, ... }:

{
  options.modules.proton-mail.enable = lib.mkEnableOption "Proton Mail desktop app";

  config = lib.mkIf config.modules.proton-mail.enable {
    home.packages = [
      (pkgs.callPackage ./pkgs/proton-mail.nix {})
    ];
  };
}
