{ ... }:

{
  # Keeps the two source-of-truth repos in step across machines without
  # typing pull/push. Each repo gets a systemd user unit running
  # git-sync-on-inotify: it syncs on every local file change and on the
  # interval timer, which is how changes from the other machine arrive.
  # It autocommits anything dirty as "changes from <host>", so hand-written
  # commits still matter for nix-config history; git-sync only moves them.
  # A diverged branch that won't rebase cleanly stops the unit; check with
  # `systemctl --user status git-sync-<name>`.
  flake.modules.homeManager.terminal-feature-git-sync = { config, ... }:
    let
      home = config.home.homeDirectory;
    in
    {
      services.git-sync = {
        enable = true;
        repositories = {
          nix-config = {
            path = "${home}/nix-config";
            uri = "git@github.com:ImperaLuna/nix-config.git";
            interval = 120;
          };
          skills = {
            path = "${home}/Skills";
            uri = "git@github.com:ImperaLuna/Skills.git";
            interval = 60;
          };
        };
      };
    };
}
