{ mkHost, config, ... }:

{
  RyzenShine = mkHost {
    system = "x86_64-linux";
    hostPath = ./.;
    username = "imperaluna";
    userConfig = ../.users/imperaluna;
    homeProfile = "desktop";
    extraSystemModules = [
      config.flake.nixosModules._systems-role-desktop
    ];
  };
}
