{ pkgs, lib, config, ... }:

{
  options.modules.ripgrep.enable = lib.mkEnableOption "ripgrep";

  config = lib.mkIf config.modules.ripgrep.enable {
    home.packages = [ pkgs.ripgrep ];
  };
}
