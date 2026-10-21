{ ... }:

{
  flake.modules.homeManager.terminal-feature-tealdeer = {
    programs.tealdeer = {
      enable = true;
      # enableAutoUpdates (on by default) refreshes the page cache on a timer.
      settings.updates = {
        auto_update = true;
        auto_update_interval_hours = 24;
      };
    };
  };
}
