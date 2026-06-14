{ mkHost, config, ... }:

{
  RyzenShine = mkHost {
    system = "x86_64-linux";
    hostPath = ./.;
    username = "imperaluna";
    userConfig = ../../../modules/credentials/imperaluna;
    homeProfile = "desktop";
    extraSystemModules = [
      config.flake.nixosModules._systems-role-desktop
    ];
  };
}
