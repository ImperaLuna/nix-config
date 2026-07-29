{ pkgs, ... }:
let
  fzf = "${pkgs.fzf}/bin/fzf";
  eza = "${pkgs.eza}/bin/eza";
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
      local -i at_end
      local -a candidates display_candidates child_dirs fzf_args

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
        if (( ''${#candidates} )); then
          at_end=0
        else
          candidates=("$base_dir")
          at_end=1
        fi

        display_candidates=()
        for candidate in "''${candidates[@]}"; do
          display="$candidate"
          [[ "$base_dir" == "." && "$display" == ./* ]] && display="''${display#./}"
          display="''${display%/}"
          display_candidates+=("$display")
        done

        fzf_args=(
          --expect=left,right
          --reverse
          --query="$prefix"
          --header='←/→ navigate  ENTER insert  ESC cancel'
          --preview='${eza} --tree --level=2 --color=always --icons=always -- {}'
          --preview-window='right:60%'
        )
        (( at_end )) && fzf_args+=(--bind 'right:ignore')
        [[ "$base_dir" == "." || "$base_dir" == "/" ]] && fzf_args+=(--bind 'left:ignore')

        out="$(
          print -rl -- "''${display_candidates[@]}" |
            command ${fzf} $fzf_args
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
