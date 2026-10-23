{ mkHost, config, ... }:

{
  RyzenShine = mkHost {
    system = "x86_64-linux";
    hostPath = ./.;
    username = "imperaluna";
    userConfig = ../.users/imperaluna;
    extraSystemModules = [
      config.flake.nixosModules._systems-role-desktop
      {
        home-manager.users.imperaluna.imports = [
          config.flake.modules.homeManager.terminal-feature-claude-remote-control
        ];
      }
    ];
  };
}
