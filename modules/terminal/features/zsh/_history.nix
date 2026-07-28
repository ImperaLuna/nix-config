{ ... }:

let
  theme = import ../../../_lib/theme.nix;
in
{
  programs.zsh.initContent = ''
    _fzf_history_delete() {
      emulate -L zsh
      local +h HISTORY_IGNORE=
      local -a ignore nums
      local num

      fc -pa "$HISTFILE"
      nums=( ''${(Onu)@} )
      for num in "''${nums[@]}"; do
        [[ -n "$num" && -n "''${history[$num]}" ]] && ignore+=("''${(b)history[$num]}")
      done

      if (( ''${#ignore} )); then
        HISTORY_IGNORE="(''${(j:|:)ignore})"
        fc -W
      fi

      fc -P
      fc -p "$HISTFILE"
      fc -R "$HISTFILE"
    }

    fzf-history-widget() {
      emulate -L zsh
      local out key selections line selected_line selected_cmd
      local -a nums

      while true; do
        fc -pa "$HISTFILE"
        out="$({
          fc -rt '%Y-%m-%d %H:%M' -l 1 |
            awk '{ if (!seen[$0]++) print $0 }' |
            awk '{ print $1 "  " $2, substr($0, index($0, $3)) }'
        } | fzf \
          --ansi \
          --expect=ctrl-d \
          --header='ENTER: use command  CTRL-D: delete selected  ESC: cancel' \
          --height=100% \
          --layout=reverse \
          --multi \
          --preview='printf "%s\\n" {2..} | bat --color=always --style=plain --paging=never --language=sh' \
          --preview-window='down:40%:wrap:border-top' \
          --prompt=' History > ' \
          --scheme=history \
          --with-nth=1.. \
          --color='bg:${theme.bg},bg+:${theme.bgAlt},fg:${theme.fg},fg+:${theme.bg},hl:${theme.primary},hl+:${theme.primary},pointer:${theme.primary},marker:${theme.success},prompt:${theme.primary},info:${theme.info},header:${theme.warning},spinner:${theme.secondary}'
        )"
        fc -P

        [[ -z "$out" ]] && zle redisplay && return

        key="''${out%%$'\n'*}"
        if [[ "$key" == ctrl-d ]]; then
          selections="''${out#*$'\n'}"
          nums=()
          while IFS= read -r line; do
            [[ -n "$line" ]] && nums+=("$(printf '%s\n' "$line" | awk '{print $1}')")
          done <<< "$selections"

          (( ''${#nums} )) && _fzf_history_delete "''${nums[@]}"
          continue
        fi

        selected_line="''${out#*$'\n'}"
        [[ "$selected_line" == "$out" ]] && selected_line="$out"
        selected_line="$(printf '%s\n' "$selected_line" | sed -E '/^[[:space:]]*$/d' | sed -n '1p')"
        selected_line="''${selected_line%$'\r'}"
        [[ -z "$selected_line" ]] && zle redisplay && return

        selected_cmd="$(printf '%s\n' "$selected_line" | sed -E 's/^[[:space:]]*[0-9]+[[:space:]]+[0-9-]+[[:space:]]+[0-9:]+[[:space:]]+//')"
        BUFFER="$selected_cmd"
        CURSOR=''${#BUFFER}
        zle redisplay
        return
      done
    }

    zle -N fzf-history-widget
    bindkey '^R' fzf-history-widget
    bindkey -M emacs '^R' fzf-history-widget
    bindkey -M viins '^R' fzf-history-widget
    bindkey -M vicmd '^R' fzf-history-widget
  '';
}
