{ ... }:

{
  # Removes Nova worktrees (~/Projects/Nova/.worktrees and Claude Code's
  # .claude/worktrees) whose pull request is merged or closed. Claude
  # threads add them to test on this machine and often end before their PR
  # does, so nobody removes them by hand (about 1 GB each). A worktree with
  # no PR (a local experiment) or an open one stays, and so does one a
  # process is working in. Uncommitted changes are saved as a patch first.
  # It also empties Nova's git-ignored scratch dir (~/Projects/Nova/.scratch)
  # of entries untouched for a week, and removes stray ~/Projects/nova-*
  # folders, which Nova's AGENTS.md forbids, after the same week.
  flake.modules.homeManager.dev-feature-nova-worktree-cleanup = { pkgs, ... }:
    let
      cleanup = pkgs.writeShellApplication {
        name = "nova-worktree-cleanup";
        runtimeInputs = with pkgs; [ coreutils findutils gawk gh git gnugrep ];
        text = ''
          repo="$HOME/Projects/Nova"
          github_repo="ImperaLuna/Nova"
          patches="''${XDG_STATE_HOME:-$HOME/.local/state}/nova-worktree-cleanup"
          [ -e "$repo/.git" ] || exit 0
          mkdir -p "$patches"

          in_use() {
            local cwd
            for link in /proc/[0-9]*/cwd; do
              cwd=$(readlink "$link" 2>/dev/null) || continue
              case "$cwd/" in "$1"/*) return 0 ;; esac
            done
            return 1
          }

          git -C "$repo" worktree list --porcelain | awk '/^worktree /{ print substr($0, 10) }' |
            while read -r worktree; do
              case "$worktree" in
                "$repo/.worktrees/"* | "$repo/.claude/worktrees/"*) ;;
                *) continue ;;
              esac
              commit=$(git -C "$worktree" rev-parse HEAD) || continue
              if ! states=$(gh api "repos/$github_repo/commits/$commit/pulls" --jq '.[].state'); then
                echo "skip $worktree: can't ask GitHub about $commit"
                continue
              fi
              if [ -z "$states" ]; then
                echo "keep $worktree: no pull request"
                continue
              fi
              if printf '%s\n' "$states" | grep -qx open; then
                echo "keep $worktree: pull request still open"
                continue
              fi
              if in_use "$worktree"; then
                echo "keep $worktree: a process is working in it"
                continue
              fi
              patch="$patches/$(basename "$worktree")-$(date +%F).patch"
              git -C "$worktree" diff HEAD > "$patch"
              saved=""
              if [ -s "$patch" ]; then saved=" (changes in $patch)"; else rm "$patch"; fi
              git -C "$repo" worktree remove --force "$worktree"
              echo "removed $worktree$saved"
            done

          git -C "$repo" worktree prune
          find "$patches" -name '*.patch' -mtime +30 -delete

          # Scratch that nobody touched for a week: the thread that made it is done.
          stale_days=7
          for dir in "$repo/.scratch"/* "$HOME/Projects"/nova-*; do
            [ -d "$dir" ] || continue
            [ -z "$(find "$dir" -newermt "$stale_days days ago" -print -quit)" ] || continue
            if in_use "$dir"; then
              echo "keep $dir: a process is working in it"
              continue
            fi
            rm -rf "$dir"
            echo "removed $dir"
          done
        '';
      };
    in
    {
      home.packages = [ cleanup ];

      systemd.user.services.nova-worktree-cleanup = {
        Unit.Description = "Remove finished Nova worktrees and stale Nova scratch";
        Service = {
          Type = "oneshot";
          ExecStart = "${cleanup}/bin/nova-worktree-cleanup";
        };
      };

      systemd.user.timers.nova-worktree-cleanup = {
        Unit.Description = "Remove finished Nova worktrees daily";
        Timer = {
          OnCalendar = "daily";
          Persistent = true;
        };
        Install.WantedBy = [ "timers.target" ];
      };
    };
}
