{ pkgs, ... }:
let
  fzf = "${pkgs.fzf}/bin/fzf";
  eza = "${pkgs.eza}/bin/eza";
in

{
  programs.zsh.initContent = ''
    _zsh_command_help_preview() {
      emulate -L zsh
      local cmd="$1"
      local page

      if (( $+commands[tldr] )); then
        page="$(command tldr "$cmd" 2>/dev/null)"
        if [[ -n "$page" ]]; then
          if (( $+commands[bat] )); then
            print -r -- "$page" | command bat --paging=never --language=markdown
          else
            print -r -- "$page"
          fi
          return 0
        fi
      fi

      if (( $+commands[bat] )); then
        command man "$cmd" 2>/dev/null | command bat --paging=never --language=man
      else
        command man "$cmd" 2>/dev/null
      fi
    }

    _zsh_command_help_menu() {
      emulate -L zsh
      if [[ ! -x "${fzf}" ]]; then
        zle .expand-or-complete
        return 0
      fi
      local token="$1"
      local selected
      local -a candidates

      candidates=( ''${(k)commands} ''${(k)builtins} ''${(k)aliases} )
      typeset -U candidates
      selected="$(
        print -rl -- $candidates |
          command ${fzf} \
            --query="$token" \
            --exact \
            --preview='_zsh_command_help_preview {}' \
            --preview-window='right:60%' \
            --header='ENTER: insert command  preview: TLDR, then MAN' \
            --prompt='Commands> '
      )"

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

      BUFFER="$start$1$after"
      CURSOR=$(( ''${#start} + ''${#1} ))
    }

    _zsh_cd_menu() {
      emulate -L zsh
      if [[ ! -x "${fzf}" ]]; then
        zle .expand-or-complete
        return 0
      fi
      setopt localoptions nullglob

      local token="$1"
      local path="$token"
      local base_dir prefix
      local out key selected selected_path
      local -a candidates display_candidates child_dirs

      if [[ "$path" == "~" || "$path" == "~/"* ]]; then
        path="$HOME''${path#\~}"
      fi

      if [[ "$token" == */ || -d "$path" ]]; then
        base_dir="$path"
        prefix=""
      else
        base_dir="''${path:h}"
        prefix="''${path:t}"
      fi
      [[ -n "$base_dir" ]] || base_dir=.
      [[ "$base_dir" != "/" ]] && base_dir="''${base_dir%/}"
      [[ -d "$base_dir" ]] || return 0

      while true; do
        candidates=()
        if [[ -n "$prefix" ]]; then
          candidates=( "$base_dir"/''${~prefix}*(N/) )
        else
          candidates=( "$base_dir"/*(N/) )
        fi
        (( ''${#candidates} )) || candidates=("$base_dir")

        display_candidates=()
        for candidate in "''${candidates[@]}"; do
          display="$candidate"
          [[ "$base_dir" == "." && "$display" == ./* ]] && display="''${display#./}"
          display="''${display%/}"
          display_candidates+=("$display")
        done

        out="$(
          print -rl -- "''${display_candidates[@]}" |
            command ${fzf} \
              --expect=left,right \
              --reverse \
              --query="$prefix" \
              --header='←/→ navigate  ENTER insert  ESC cancel' \
              --preview='${eza} --tree --level=2 --color=always --icons=always -- {}' \
              --preview-window='right:60%'
        )"
        [[ -n "$out" ]] || return 0

        key="''${out%%$'\n'*}"
        if [[ "$out" == *$'\n'* ]]; then
          selected="''${out#*$'\n'}"
        else
          selected="$out"
        fi
        [[ -n "$selected" ]] || return 0
        case "$key" in
          right)
            selected_path="$selected"
            [[ "$selected_path" == "~"* ]] && selected_path="$HOME''${selected_path#\~}"
            if [[ -d "$selected_path" && "$selected_path" != "$base_dir" ]]; then
              child_dirs=( "$selected_path"/*(N/) )
              (( ''${#child_dirs} )) || continue
              base_dir="$selected_path"
              prefix=""
            else
              continue
            fi
            ;;
          left)
            parent_dir="''${base_dir:h}"
            [[ "$parent_dir" == "$base_dir" ]] && continue
            base_dir="$parent_dir"
            prefix=""
            ;;
          *)
            if [[ "$token" == "~"* && "$selected" == "$HOME"/* ]]; then
              selected="~''${selected#$HOME}"
            fi
            _zsh_replace_current_token "$selected"
            zle redisplay
            return 0
            ;;
        esac
      done
    }

    _zsh_tab_complete_or_cd_menu() {
      emulate -L zsh
      local line="''${BUFFER[1,$CURSOR]}"
      local token="''${line##*[[:space:]]}"

      if [[ "$line" != *[[:space:]]* ]]; then
        _zsh_command_help_menu "$token"
      elif [[ "$line" =~ '^[[:space:]]*cd([[:space:]]|$)' ]]; then
        _zsh_cd_menu "$token"
      else
        zle .expand-or-complete
      fi
    }

    zle -N _zsh_tab_complete_or_cd_menu
    bindkey -M emacs '^I' _zsh_tab_complete_or_cd_menu
    bindkey -M viins '^I' _zsh_tab_complete_or_cd_menu 2>/dev/null
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
  '';
}
