{ pkgs, ... }:
let
  theme = import ../../../_lib/theme.nix;
  fzf = "${pkgs.fzf}/bin/fzf";
  tldr = "${pkgs.tealdeer}/bin/tldr";
  bat = "${pkgs.bat}/bin/bat";
  man = "${pkgs.man}/bin/man";
  pathBrowser = import ../../_lib/fzf-path-browser.nix { inherit pkgs; };
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

    _zsh_path_menu() {
      emulate -L zsh
      local output path replacement
      local -a selected replacements

      output="$(${pathBrowser.package}/bin/fzf-path-browser "$1" "$2")" || return 0
      [[ -n "$output" ]] || return 0
      selected=("''${(@f)output}")

      for path in "''${selected[@]}"; do
        # fzf can accept the query when there is no selected row (for
        # example immediately after a reload). Never turn that into an empty quoted argument.
        [[ -n "$path" ]] || continue
        case "$path" in
          "~") replacement='~' ;;
          "~/"*) replacement="~/''${(q)path[3,-1]}" ;;
          *) replacement="''${(q)path}" ;;
        esac
        replacements+=("$replacement")
      done
      (( ''${#replacements[@]} > 0 )) || return 0
      _zsh_replace_current_token "''${(j: :)replacements}" literal
      zle redisplay
    }

    _zsh_tab_complete_or_path_menu() {
      emulate -L zsh
      local line="''${BUFFER[1,$CURSOR]}"
      local token="''${line##*[[:space:]]}"

      if [[ "$line" != *[[:space:]]* && "$token" != */* ]]; then
        _zsh_command_help_menu "$token"
      elif [[ "$line" =~ '^[[:space:]]*cd([[:space:]]|$)' ]]; then
        _zsh_path_menu directories "$token"
      elif [[ "$line" =~ '^[[:space:]]*(${pathBrowser.commandPattern})([[:space:]]|$)' ]]; then
        _zsh_path_menu paths "$token"
      else
        zle fzf-tab-complete
      fi
    }

    zle -N _zsh_tab_complete_or_path_menu
    bindkey -M emacs '^I' _zsh_tab_complete_or_path_menu
    bindkey -M viins '^I' _zsh_tab_complete_or_path_menu 2>/dev/null
    function rebuild() {
      local flakePath

      for candidate in ~/nix-config ~/homelab/nix-config; do
        if [[ -f "$candidate/flake.nix" ]]; then
          flakePath="$candidate"
          break
        fi
      done

      if [[ -z "$flakePath" ]]; then
        print -u2 "rebuild: no flake found at ~/nix-config or ~/homelab/nix-config"
        return 1
      fi

      sudo SSH_AUTH_SOCK="''${SSH_AUTH_SOCK:-}" nixos-rebuild switch --flake "$flakePath#$(hostname)" "$@"
    }

    function upgrade() {
      local flakePath

      for candidate in ~/nix-config ~/homelab/nix-config; do
        if [[ -f "$candidate/flake.nix" ]]; then
          flakePath="$candidate"
          break
        fi
      done

      if [[ -z "$flakePath" ]]; then
        print -u2 "upgrade: no flake found at ~/nix-config or ~/homelab/nix-config"
        return 1
      fi

      nix flake update --flake "$flakePath" "$@" || return $?

      sudo SSH_AUTH_SOCK="''${SSH_AUTH_SOCK:-}" nixos-rebuild switch --flake "$flakePath#$(hostname)"
    }

    function homeswitch() {
      local flakePath
      local hostName="$(hostname)"
      local configName
      local hmAttr
      local activationPkg

      for candidate in ~/nix-config ~/homelab/nix-config; do
        if [[ -f "$candidate/flake.nix" ]]; then
          flakePath="$candidate"
          break
        fi
      done

      if [[ -z "$flakePath" ]]; then
        print -u2 "homeswitch: no flake found at ~/nix-config or ~/homelab/nix-config"
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

      env HOME_MANAGER_BACKUP_EXT=hm-backup HOME_MANAGER_BACKUP_OVERWRITE=1 "$activationPkg/activate"
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
