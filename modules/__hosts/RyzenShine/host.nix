{ mkHost, config, ... }:

{
  RyzenShine = mkHost {
    system = "x86_64-linux";
    hostPath = ./.;
    username = "imperaluna";
    userConfig = ../../../home/users/imperaluna.nix;
    homeProfile = "desktop";
    extraSystemModules = [
      config.flake.nixosModules.system-stack-desktop
    ];
  };
}
