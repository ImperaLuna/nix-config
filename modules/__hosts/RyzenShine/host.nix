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
          # Workshop wallpapers through linux-wallpaperengine, on this PC only.
          { programs.nova.features.wallpaper-engine.enable = true; }
        ];
      }
    ];
  };
}
