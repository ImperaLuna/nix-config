{ lib, config, ... }:

{
  options.modules.syncthing.enable = lib.mkEnableOption "syncthing";

  config = lib.mkIf config.modules.syncthing.enable {
    services.syncthing = {
      enable = true;
      user = "imperaluna";
      group = "users";
      dataDir = "/home/imperaluna/Sync";
      configDir = "/home/imperaluna/.config/syncthing";
      openDefaultPorts = true;
    };
  };
}
