{ lib, config, ... }:

{
  imports = [
    ./zapzap.nix
    ./discord.nix
    ./ferdium.nix
    ./onlyoffice.nix
    ./thunderbird.nix
    ./tutanota.nix
  ];

  options.modules.apps.enable = lib.mkEnableOption "general purpose apps";

  config = lib.mkIf config.modules.apps.enable {
    modules = {
      zapzap.enable     = true;
      discord.enable    = true;
      ferdium.enable    = true;
      onlyoffice.enable = true;
      thunderbird.enable = true;
      tutanota.enable   = true;
    };
  };
}
