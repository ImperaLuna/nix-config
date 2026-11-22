{ ... }:

{
  # Keeps Cargo's build caches under ~/Projects from filling the drive. Cargo
  # never deletes old artifacts, and agent threads switching branches add a
  # new set each time: Nova Files' target/ reached 27 GB in three days and
  # Nova's 13 GB. Nix builds don't use these folders, so losing them only
  # costs one local recompile.
  #
  # Daily, for every target/ next to a Cargo.toml (worktrees included):
  # incremental caches untouched for 3 days go, and a target/ still over
  # 15 GB after that is removed whole. A project a process is working in is
  # left alone.
  flake.modules.homeManager.dev-feature-cargo-target-cleanup = { pkgs, ... }:
    let
      cleanup = pkgs.writeShellApplication {
        name = "cargo-target-cleanup";
        runtimeInputs = with pkgs; [ coreutils findutils ];
        text = ''
          projects="$HOME/Projects"
          stale_days=3
          max_bytes=$((15 * 1024 * 1024 * 1024))
          [ -d "$projects" ] || exit 0

          in_use() {
            local cwd
            for link in /proc/[0-9]*/cwd; do
              cwd=$(readlink "$link" 2>/dev/null) || continue
              case "$cwd/" in "$1"/*) return 0 ;; esac
            done
            return 1
          }

          find "$projects" -maxdepth 6 -type d -name target -prune -print |
            while read -r target; do
              project=$(dirname "$target")
              [ -f "$project/Cargo.toml" ] || continue
              if in_use "$project"; then
                echo "keep $target: a process is working in $project"
                continue
              fi
              before=$(du -sb "$target" | cut -f1)
              find "$target" -mindepth 3 -maxdepth 3 -path '*/incremental/*' -type d \
                -mtime +"$stale_days" -exec rm -rf {} +
              after=$(du -sb "$target" | cut -f1)
              if [ "$after" -gt "$max_bytes" ]; then
                rm -rf "$target"
                echo "removed $target ($((after / 1024 / 1024)) MiB, over the 15 GiB limit)"
              elif [ "$after" -lt "$before" ]; then
                echo "trimmed $target: $((before / 1024 / 1024)) -> $((after / 1024 / 1024)) MiB"
              fi
            done
        '';
      };
    in
    {
      home.packages = [ cleanup ];

      systemd.user.services.cargo-target-cleanup = {
        Unit.Description = "Trim Cargo build caches under ~/Projects";
        Service = {
          Type = "oneshot";
          ExecStart = "${cleanup}/bin/cargo-target-cleanup";
          Nice = 19;
          IOSchedulingClass = "idle";
        };
      };

      systemd.user.timers.cargo-target-cleanup = {
        Unit.Description = "Trim Cargo build caches under ~/Projects daily";
        Timer = {
          OnCalendar = "daily";
          Persistent = true;
        };
        Install.WantedBy = [ "timers.target" ];
      };
    };
}
