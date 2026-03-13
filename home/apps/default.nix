{ lib, config, ... }:

{
  imports = [
    ./zapzap.nix
    ./discord.nix
  ];

  options.modules.apps.enable = lib.mkEnableOption "general purpose apps";

  config = lib.mkIf config.modules.apps.enable {
    modules = {
      zapzap.enable  = true;
      discord.enable = true;
    };
  };
}
