{ mkHost, ... }:

{
  DuskNova = mkHost {
    system = "x86_64-linux";
    hostPath = ./.;
    username = "dusknova";
    userConfig = ../../../home/users/imperaluna.nix;
    homeProfile = "server";
  };
}
