{ ... }:

{
  flake.modules.homeManager.terminal-feature-direnv = {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
