{ lib, config, ... }:

{
  options.modules.direnv.enable = lib.mkEnableOption "direnv";

  config = lib.mkIf config.modules.direnv.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
