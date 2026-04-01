{ lib, config, ... }:

{
  imports = [
    ./discord.nix
    ./ferdium.nix
    ./onlyoffice.nix
    ./qupath.nix
  ];

  options.modules.apps.enable = lib.mkEnableOption "general purpose apps";

  config = lib.mkIf config.modules.apps.enable {
    modules = {
      discord.enable    = true;
      ferdium.enable    = true;
      onlyoffice.enable = true;
      qupath.enable     = true;
    };
  };
}
