{ ... }:

{
  flake.modules.homeManager.terminal-feature-tmux = { ... }: {
    programs.tmux = {
      enable = true;
      historyLimit = 100000;
      mouse = true;
    };
  };
}
