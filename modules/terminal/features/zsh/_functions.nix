{ pkgs, ... }:
let
  theme = import ../../../_lib/theme.nix;
  fzf = "${pkgs.fzf}/bin/fzf";
  tldr = "${pkgs.tealdeer}/bin/tldr";
  bat = "${pkgs.bat}/bin/bat";
  man = "${pkgs.man}/bin/man";
in

{
  programs.zsh.initContent = ''

    _zsh_command_help_menu() {
      emulate -L zsh
      if [[ ! -x "${fzf}" ]]; then
        zle .expand-or-complete
        return 0
      fi
      local token="$1"
      local selected mode_file
      local -a candidates fzf_args

      candidates=( ''${(k)commands} ''${(k)builtins} ''${(k)aliases} )
      typeset -U candidates
      mode_file="$(mktemp)"
      print -r -- tldr > "$mode_file"
      local -x FZF_COMMAND_HELP_MODE_FILE="$mode_file"

      fzf_args=(
        --query="$token"
        --exact
        --color='prompt:${theme.primary},header:${theme.secondary},border:${theme.primary},label:${theme.primary}'
        --ansi
        --with-shell='bash -c'
        --preview='if [ "$(cat "$FZF_COMMAND_HELP_MODE_FILE" 2>/dev/null)" = tldr ]; then page="$(${tldr} {} 2>/dev/null)"; if [ -n "$page" ]; then printf "%s\n" "$page" | ${bat} --paging=never --language=markdown; else ${man} {} 2>/dev/null | ${bat} --paging=never --language=man; fi; else ${man} {} 2>/dev/null | ${bat} --paging=never --language=man; fi'
        --preview-window='right:60%'
        --preview-label=' TLDR '
        --header='left: TLDR  right: MAN'
        --prompt='Commands> '
        --bind='left:execute-silent(printf "tldr\n" > "$FZF_COMMAND_HELP_MODE_FILE")+change-preview-label( TLDR )+refresh-preview'
        --bind='right:execute-silent(printf "man\n" > "$FZF_COMMAND_HELP_MODE_FILE")+change-preview-label( MAN )+refresh-preview'
      )

      selected="$(
        print -rl -- $candidates |
          command ${fzf} $fzf_args
      )"
      rm -f "$mode_file"

      [[ -n "$selected" ]] || return 0
      _zsh_replace_current_token "$selected"
      zle redisplay
    }

    _zsh_replace_current_token() {
      emulate -L zsh
      local line="''${BUFFER[1,$CURSOR]}"
      local token="''${line##*[[:space:]]}"
      local start="''${line%$token}"
      local after="''${BUFFER[$((CURSOR + 1)),-1]}"
      local replacement
      local literal="''${2:-}"

      if [[ "$literal" == literal ]]; then
        replacement="$1"
      else
        case "$1" in
          "~") replacement='~' ;;
          "~/"*) replacement="~/''${(q)1[3,-1]}" ;;
          *) replacement="''${(q)1}" ;;
        esac
      fi
      BUFFER="$start$replacement$after"
      CURSOR=$(( ''${#start} + ''${#replacement} ))
    }

    _zsh_tab_complete() {
      emulate -L zsh
      local line="''${BUFFER[1,$CURSOR]}"
      local token="''${line##*[[:space:]]}"

      # Only command-name completion is special. Once a command is present,
      # let Zsh's completion definitions decide whether the context contains
      # paths, options, subcommands, hosts, package names, and so on. fzf-tab
      # then gives every completion type the same UI without a command allowlist.
      if [[ "$line" != *[[:space:]]* && "$token" != */* ]]; then
        _zsh_command_help_menu "$token"
      else
        zle fzf-tab-complete
      fi
    }

    zle -N _zsh_tab_complete
    bindkey -M emacs '^I' _zsh_tab_complete
    bindkey -M viins '^I' _zsh_tab_complete 2>/dev/null
    function rebuild() {
      local flakePath

      for candidate in ~/nix-config; do
        if [[ -f "$candidate/flake.nix" ]]; then
          flakePath="$candidate"
          break
        fi
      done

      if [[ -z "$flakePath" ]]; then
        print -u2 "rebuild: no flake found at ~/nix-config"
        return 1
      fi

      sudo nixos-rebuild switch --flake "$flakePath" "$@" || return $?
      exec zsh
    }

    function upgrade() {
      local flakePath

      for candidate in ~/nix-config; do
        if [[ -f "$candidate/flake.nix" ]]; then
          flakePath="$candidate"
          break
        fi
      done

      if [[ -z "$flakePath" ]]; then
        print -u2 "upgrade: no flake found at ~/nix-config"
        return 1
      fi

      # Start from the latest config and lock so the update can't diverge
      # from what other machines already pushed.
      if ! git -C "$flakePath" pull --rebase --autostash; then
        print -u2 "upgrade: git pull failed in $flakePath, resolve it before upgrading"
        return 1
      fi

      # Authenticated GitHub API calls get 5000 req/h instead of 60.
      local nixConfig="''${NIX_CONFIG:-}"
      local ghToken
      if command -v gh >/dev/null 2>&1 && ghToken="$(gh auth token 2>/dev/null)" && [[ -n "$ghToken" ]]; then
        nixConfig+=$'\n'"access-tokens = github.com=$ghToken"
      fi

      NIX_CONFIG="$nixConfig" nix flake update --flake "$flakePath" "$@" || return $?

      if [[ -e /etc/NIXOS ]]; then
        sudo nixos-rebuild switch --flake "$flakePath" || return $?
      else
        local configName="''${HM_CONFIG_NAME:-$(hostname)}"
        if ! command -v home-manager >/dev/null 2>&1; then
          print -u2 "upgrade: home-manager is not available"
          return 1
        fi
        home-manager switch --flake "$flakePath#$configName" || return $?
      fi

      exec zsh
    }

    function homeswitch() {
      local flakePath
      local hostName="$(hostname)"
      local configName
      local hmAttr
      local activationPkg

      for candidate in ~/nix-config; do
        if [[ -f "$candidate/flake.nix" ]]; then
          flakePath="$candidate"
          break
        fi
      done

      if [[ -z "$flakePath" ]]; then
        print -u2 "homeswitch: no flake found at ~/nix-config"
        return 1
      fi

      if [[ -n "''${HM_CONFIG_NAME:-}" ]]; then
        configName="$HM_CONFIG_NAME"
      else
        configName="$hostName"
      fi

      if nix eval "path:$flakePath#homeConfigurations.\"$configName\".activationPackage.drvPath" >/dev/null 2>&1; then
        hmAttr="homeConfigurations.\"$configName\".activationPackage"
      else
        hmAttr="nixosConfigurations.\"$hostName\".config.home-manager.users.$USER.home.activationPackage"
      fi

      activationPkg="$(nix build "path:$flakePath#$hmAttr" --no-link --print-out-paths "$@")"
      if [[ -z "$activationPkg" ]]; then
        print -u2 "homeswitch: failed to build activation package for $USER using $hmAttr"
        return 1
      fi

      if pgrep -x zen >/dev/null || pgrep -x zen-beta >/dev/null; then
        print -u2 "homeswitch: Zen is running; close it first so declarative spaces/pins can be applied."
        return 1
      fi

      env HOME_MANAGER_BACKUP_EXT=hm-backup HOME_MANAGER_BACKUP_OVERWRITE=1 "$activationPkg/activate" || return $?
      exec zsh
    }

    # `nova-dev <PR number>` runs that PR's branch in place of the running
    # bar; Ctrl+C or closing the terminal puts the old bar back. Each PR gets
    # a worktree at $NOVA_DEV_DIR/.worktrees/pr-<N>, ignored through
    # .git/info/exclude. Each run first removes the worktrees of merged or
    # closed PRs, keeping any with uncommitted changes or with a process
    # (such as a shell) working inside. The main checkout never switches
    # branches.
    #
    # While nova-dev runs, `nova` works from any folder: it's a link in
    # $NOVA_DEV_BIN (on PATH) to the PR's build. The link goes away when
    # nova-dev exits, so `nova` is the installed one again. Closing the
    # terminal can skip that cleanup; the next run replaces the link. The
    # latest run wins even inside another checkout: direnv's PATH_add puts
    # that checkout's target/debug first, so a precmd hook (after direnv's,
    # which runs first) moves $NOVA_DEV_BIN back in front at every prompt.
    # With no run active the folder is empty and the checkout's build wins.
    NOVA_DEV_BIN="''${XDG_STATE_HOME:-$HOME/.local/state}/nova-dev/bin"
    typeset -U path
    path=("$NOVA_DEV_BIN" $path)
    function _nova_dev_bin_first() {
      path=("$NOVA_DEV_BIN" $path)
    }
    autoload -Uz add-zsh-hook
    add-zsh-hook precmd _nova_dev_bin_first
    function nova-dev() {
      local main="''${NOVA_DEV_DIR:-$HOME/Projects/Nova}"
      local pr="$1"
      if [[ $# -ne 1 || "$pr" != <-> ]]; then
        print -u2 "usage: nova-dev <PR number>"
        return 1
      fi
      local worktrees="$main/.worktrees"
      local exclude="$main/.git/info/exclude"
      grep -qxF "/.worktrees/" "$exclude" 2>/dev/null || print "/.worktrees/" >>"$exclude"

      local old old_pr state cwd in_use
      for old in "$worktrees"/pr-<->(N); do
        old_pr="''${old##*/pr-}"
        state="$(cd "$main" && gh pr view "$old_pr" --json state --jq .state)" || continue
        [[ "$state" == OPEN ]] && continue
        in_use=
        for cwd in /proc/<->/cwd(N); do
          cwd="''${cwd:A}"
          if [[ "$cwd" == "''${old:A}" || "$cwd" == "''${old:A}"/* ]]; then
            in_use=1
            break
          fi
        done
        if [[ -n "$(git -C "$old" status --porcelain)" ]]; then
          print -u2 "nova-dev: keeping $old (PR $old_pr is $state): it has uncommitted changes"
        elif [[ -n "$in_use" ]]; then
          print -u2 "nova-dev: keeping $old (PR $old_pr is $state): a process is working in it"
        else
          git -C "$main" worktree remove "$old" && print "nova-dev: removed $old (PR $old_pr is $state)"
        fi
      done
      git -C "$main" worktree prune

      local branch repo="$worktrees/pr-$pr"
      branch="$(cd "$main" && gh pr view "$pr" --json headRefName --jq .headRefName)" || return $?
      git -C "$main" fetch --quiet origin "$branch" || return $?
      if [[ -e "$repo" ]]; then
        if [[ -n "$(git -C "$repo" status --porcelain)" ]]; then
          print -u2 "nova-dev: $repo has uncommitted changes; commit or stash them first"
          return 1
        fi
        git -C "$repo" checkout --quiet --detach "origin/$branch" || return $?
      else
        git -C "$main" worktree add --quiet --detach "$repo" "origin/$branch" || return $?
      fi
      print "nova-dev: PR $pr ($branch) at $(git -C "$repo" log -1 --format='%h %s')"
      cd "$repo" || return $?
      mkdir -p "$NOVA_DEV_BIN" && ln -sfn "$repo/target/debug/nova" "$NOVA_DEV_BIN/nova"
      {
        nix develop --quiet -c just run
      } always {
        rm -f "$NOVA_DEV_BIN/nova"
      }
    }

    function ssh() {
      if [[ "$TERM" == "xterm-ghostty" ]]; then
        env TERM=xterm-256color ssh "$@"
      else
        command ssh "$@"
      fi
    }
  '';
}
