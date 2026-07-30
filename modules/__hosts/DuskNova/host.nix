{ mkHost, config, ... }:

{
  DuskNova = mkHost {
    system = "x86_64-linux";
    hostPath = ./.;
    username = "dusknova";
    userConfig = ../.users/imperaluna;
    homeProfile = "server";
    extraSystemModules = [
      config.flake.nixosModules._systems-role-server
    ];
  };
}
