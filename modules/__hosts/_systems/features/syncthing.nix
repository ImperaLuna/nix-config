{ ... }:

{
  services.syncthing = {
    enable = true;
    user = "imperaluna";
    group = "users";
    dataDir = "/home/imperaluna/Sync";
    configDir = "/home/imperaluna/.config/syncthing";
    openDefaultPorts = true;
  };
}
