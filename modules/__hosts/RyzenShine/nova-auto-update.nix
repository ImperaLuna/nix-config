{ pkgs, ... }:

# Brings each merge to Nova's main onto this PC within about an hour
# (IMP-221): an hourly timer updates the nova-rebuild input to main,
# commits flake.lock, applies the config (nixos-apply) and restarts Nova.
# If the switch fails, or Nova doesn't come back up, it puts the old
# flake.lock back, rolls back (nixos-rollback) when the system had already
# switched, and doesn't try that commit again; a newer main is tried as
# usual. It waits while a CI runner has a job, and leaves nix-config alone
# while it has uncommitted changes (someone is editing it). Every run logs
# one line to the journal (`journalctl --user -u nova-auto-update`);
# updates and failures also show a notification.
let
  update = pkgs.writeShellApplication {
    name = "nova-auto-update";
    runtimeInputs = with pkgs; [ coreutils gh git jq libnotify nix systemd ];
    text = ''
      config="$HOME/nix-config"
      github_repo="ImperaLuna/Nova"
      input="nova-rebuild"
      state="''${XDG_STATE_HOME:-$HOME/.local/state}/nova-auto-update"
      running_revision=/run/current-system/sw/share/nova/revision
      mkdir -p "$state"

      notify() { notify-send --app-name "Nova update" "$1" "$2" || true; }
      # A journal warning (systemd reads the <4> prefix) and a notification.
      fail() {
        echo "<4>$1"
        notify "Nova update failed" "$1"
      }
      locked() { jq -r --arg input "$input" '.nodes[$input].locked.rev' "$config/flake.lock"; }

      if ! main=$(gh api "repos/$github_repo/commits/main" --jq .sha); then
        echo "skip: can't ask GitHub for main"
        exit 0
      fi
      # The revision Nova records (share/nova/revision) once it's installed
      # system-wide; before that, what flake.lock pins.
      if [ -r "$running_revision" ]; then running=$(cat "$running_revision"); else running=$(locked); fi
      if [ "$running" = "$main" ]; then
        echo "current: Nova runs main ''${main:0:7}"
        exit 0
      fi
      if [ "$(cat "$state/failed" 2>/dev/null)" = "$main" ]; then
        echo "skip: main ''${main:0:7} failed to apply before; waiting for a newer main"
        exit 0
      fi
      if [ -n "$(git -C "$config" status --porcelain)" ]; then
        echo "skip: nix-config has uncommitted changes"
        exit 0
      fi
      # The switch restarts nothing the runners use, but a job's build
      # shares the CPU and nix daemon with it.
      if ! busy=$(gh api "repos/$github_repo/actions/runners" --jq '[.runners[] | select(.busy)] | length'); then
        echo "skip: can't ask GitHub whether the CI runners are busy"
        exit 0
      fi
      if [ "$busy" != 0 ]; then
        echo "skip: $busy CI runner(s) busy"
        exit 0
      fi

      cp "$config/flake.lock" "$state/flake.lock.before"
      previous=$(locked)
      if [ "$previous" != "$main" ]; then
        # nova-rebuild is a private repo: nix fetches it with gh's token.
        if ! NIX_CONFIG="access-tokens = github.com=$(gh auth token)" \
          nix flake update "$input" --flake "$config" >"$state/update.log" 2>&1; then
          fail "Couldn't update $input to main ''${main:0:7} (see $state/update.log)."
          exit 1
        fi
        # main may have moved on since it was asked for.
        main=$(locked)
        git -C "$config" commit --quiet -m "$input: Nova main ''${main:0:7}" -- flake.lock
      fi

      undo() {
        cp "$state/flake.lock.before" "$config/flake.lock"
        if [ -n "$(git -C "$config" status --porcelain -- flake.lock)" ]; then
          git -C "$config" commit --quiet -m "$input: back to ''${previous:0:7}, main ''${main:0:7} failed to apply" -- flake.lock
        fi
        echo "$main" >"$state/failed"
      }

      system_before=$(readlink /run/current-system)
      if ! systemctl start nixos-apply; then
        undo
        if [ "$(readlink /run/current-system)" != "$system_before" ]; then systemctl start nixos-rollback || true; fi
        fail "Applying Nova main ''${main:0:7} failed (see /var/log/nixos-apply.log); kept ''${previous:0:7}."
        exit 1
      fi

      # A switch doesn't restart user services; Nova keeps running the old
      # build until it's restarted.
      systemctl --user daemon-reload
      systemctl --user restart nova.service
      healthy=false
      for _ in $(seq 60); do
        if /run/current-system/sw/bin/nova status --json 2>/dev/null |
          jq -e --arg main "$main" '.ui.state == "running" and (.revision // $main) == $main' >/dev/null; then
          healthy=true
          break
        fi
        sleep 1
      done
      if ! $healthy; then
        undo
        systemctl start nixos-rollback || true
        systemctl --user daemon-reload
        systemctl --user restart nova.service
        fail "Nova main ''${main:0:7} didn't start (see \`nova logs\`); rolled back to ''${previous:0:7}."
        exit 1
      fi
      rm -f "$state/failed"
      echo "updated: Nova ''${previous:0:7} -> main ''${main:0:7}"
      notify "Nova updated" "Now running main ''${main:0:7}."
    '';
  };
in
{
  home-manager.users.imperaluna = {
    home.packages = [ update ];

    systemd.user.services.nova-auto-update = {
      Unit.Description = "Update Nova to its main branch and apply nix-config";
      Service = {
        Type = "oneshot";
        ExecStart = "${update}/bin/nova-auto-update";
      };
    };

    systemd.user.timers.nova-auto-update = {
      Unit.Description = "Update Nova to its main branch hourly";
      Timer = {
        OnCalendar = "hourly";
        RandomizedDelaySec = "5m";
        Persistent = true;
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };
}
