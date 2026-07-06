{ ... }:

{
  flake.modules.homeManager.terminal-feature-home-manager = { ... }: {
    programs.home-manager.enable = true;
  };
}
