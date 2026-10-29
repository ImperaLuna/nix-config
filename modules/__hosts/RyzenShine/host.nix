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
        # Commands Claude sessions here run often enough that asking each
        # time only stalls them (IMP-219). Keep this list exact.
        home-manager.users.imperaluna.modules.llm-cli-tools.claudeAllow = [
          "Bash(systemctl start nixos-apply)"
          "Bash(systemctl start nixos-rollback)"
          "Bash(nix flake update nova-rebuild)"
          "Bash(nix flake update nova-rebuild --flake /home/imperaluna/nix-config)"
          "Bash(systemctl --user restart nova)"
          "Bash(nova-dev *)"
        ];
      }
    ];
  };
}
