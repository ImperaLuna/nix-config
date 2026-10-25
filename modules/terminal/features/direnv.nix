{ ... }:

{
  flake.modules.homeManager.terminal-feature-direnv =
    { config, ... }:
    {
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
        config = {
          global.hide_env_diff = true;
          # Load these .envrc files without `direnv allow`, so new Nova worktrees work on cd.
          whitelist.prefix = [
            # Covers the worktrees in ~/Projects/Nova/.worktrees too.
            "${config.home.homeDirectory}/Projects/Nova"
          ];
        };
      };
    };
}
