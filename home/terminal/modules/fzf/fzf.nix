{ pkgs, lib, config, ... }:

{
  options.modules.fzf.enable = lib.mkEnableOption "fzf";

  config = lib.mkIf config.modules.fzf.enable {
    home.packages = [ pkgs.fzf ];
  };
}
