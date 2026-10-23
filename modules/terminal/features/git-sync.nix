{ ... }:

{
  # Keeps the two source-of-truth repos in step across machines without
  # typing pull/push. Each repo gets a systemd user unit running
  # git-sync-debounced (below): it syncs once local changes go quiet, and on
  # the interval timer, which is how changes from the other machine arrive.
  # It autocommits anything dirty as "changes from <host>", so hand-written
  # commits still matter for nix-config history; git-sync only moves them.
  # A diverged branch that won't rebase cleanly stops the unit; check with
  # `systemctl --user status git-sync-<name>`.
  flake.modules.homeManager.terminal-feature-git-sync = { config, lib, pkgs, ... }:
    let
      home = config.home.homeDirectory;

      # Seconds without a file change before a sync runs.
      delays = {
        nix-config = 60;
        skills = 60;
      };

      # Upstream's git-sync-on-inotify syncs on the first file event, which
      # commits an edit before there's time to commit it by hand. This waits
      # until the tree has been quiet for GIT_SYNC_DELAY seconds instead.
      debounced = pkgs.writeShellApplication {
        name = "git-sync-debounced";
        runtimeInputs = [ pkgs.coreutils pkgs.git pkgs.inotify-tools ];
        text = ''
          cd "$GIT_SYNC_DIRECTORY"

          watch() {
            inotifywait "$GIT_SYNC_DIRECTORY" -r -e modify,move,create,delete \
              --format "%w%f" --exclude '\.git' -t "$1" 2>/dev/null
          }

          "$GIT_SYNC_COMMAND" -n -s

          while true; do
            changed=$(watch "$GIT_SYNC_INTERVAL" || true)
            if [ -z "$changed" ]; then
              echo "Syncing due to timeout"
            elif git check-ignore -q "$changed"; then
              continue
            else
              echo "Change in $changed, waiting for $GIT_SYNC_DELAY quiet seconds"
              while [ -n "$(watch "$GIT_SYNC_DELAY" || true)" ]; do :; done
              echo "Syncing"
            fi
            "$GIT_SYNC_COMMAND" -n -s
          done
        '';
      };
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

      systemd.user.services = lib.mapAttrs' (name: delay:
        lib.nameValuePair "git-sync-${name}" {
          Service = {
            Environment = [ "GIT_SYNC_DELAY=${toString delay}" ];
            ExecStart = lib.mkForce "${debounced}/bin/git-sync-debounced";
          };
        }) delays;
    };
}
