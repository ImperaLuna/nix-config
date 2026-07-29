#!/usr/bin/env bash

set -euo pipefail

list_directories() {
  local state_dir=$1
  local base candidate name
  local found=0

  base=$(<"$state_dir/base")
  while IFS= read -r -d '' candidate; do
    found=1
    name=${candidate##*/}
    printf '%s\t%s/\n' "$candidate" "$name"
  done < <(find "$base" -mindepth 1 -maxdepth 1 -type d ! -name '.*' -print0 | sort -z)

  if (( ! found )); then
    name=${base##*/}
    [[ -n $name ]] || name=/
    printf '%s\t%s/\n' "$base" "$name"
  fi
}

has_child_directory() {
  local directory=$1
  local child

  child=$(find "$directory" -mindepth 1 -maxdepth 1 -type d ! -name '.*' -print -quit)
  [[ -n $child ]]
}

reload_action() {
  local state_dir=$1
  local shell_path=$2
  local script_path=$3

  printf 'change-query()+reload-sync(%s %s list %s)+wait+first+transform-list-label(%s %s label %s)\n' \
    "$shell_path" "$script_path" "$state_dir" "$shell_path" "$script_path" "$state_dir"
}

navigate_right() {
  local state_dir=$1
  local selected=$2
  local base parent

  base=$(<"$state_dir/base")
  parent=$(dirname -- "$selected")
  if [[ ! -d $selected || $selected == "$base" || $parent != "$base" ]] || ! has_child_directory "$selected"; then
    printf 'ignore\n'
    return
  fi

  printf '%s\n' "$selected" > "$state_dir/base"
  reload_action "$state_dir" "$BASH" "$script_path"
}

navigate_left() {
  local state_dir=$1
  local base parent

  base=$(<"$state_dir/base")
  if [[ $base == / ]]; then
    printf 'ignore\n'
    return
  fi

  parent=$(dirname -- "$base")
  printf '%s\n' "$parent" > "$state_dir/base"
  reload_action "$state_dir" "$BASH" "$script_path"
}

print_label() {
  local state_dir=$1
  local base display

  base=$(<"$state_dir/base")
  case $base in
    "$HOME") display='~' ;;
    "$HOME"/*) display="~${base#"$HOME"}" ;;
    *) display=$base ;;
  esac
  printf ' %s ' "$display"
}

format_selection() {
  local mode=$1
  local selected=$2

  case $mode in
    relative)
      realpath --relative-to="$PWD" -- "$selected"
      ;;
    home)
      case $selected in
        "$HOME") printf '~\n' ;;
        "$HOME"/*) printf '~%s\n' "${selected#"$HOME"}" ;;
        *) printf '%s\n' "$selected" ;;
      esac
      ;;
    absolute)
      printf '%s\n' "$selected"
      ;;
  esac
}

browse() {
  local token=${1-}
  local path base prefix mode state_dir result

  case $token in
    '~') path=$HOME; mode=home ;;
    \~/*) path="$HOME/${token:2}"; mode=home ;;
    /*) path=$token; mode=absolute ;;
    *) path=$token; mode=relative ;;
  esac

  if [[ $token == */ || -d $path ]]; then
    base=$path
    prefix=
  elif [[ -n $path ]]; then
    base=$(dirname -- "$path")
    prefix=$(basename -- "$path")
  else
    base=.
    prefix=
  fi
  [[ -d $base ]] || return 0

  base=$(cd -- "$base" && pwd -L)
  state_dir=$(mktemp -d)
  browser_state_dir=$state_dir
  trap 'rm -rf -- "$browser_state_dir"' EXIT
  printf '%s\n' "$base" > "$state_dir/base"

  result=$(
    "$BASH" "$script_path" list "$state_dir" |
      fzf \
        --delimiter=$'\t' \
        --with-nth=2 \
        --accept-nth=1 \
        --query="$prefix" \
        --layout=reverse \
        --header='←/→ navigate  ENTER insert  ESC cancel' \
        --list-label="$("$BASH" "$script_path" label "$state_dir")" \
        --preview='eza --tree --level=2 --color=always --icons=always -- {1}' \
        --preview-window='right:60%' \
        --bind="right:transform($BASH $script_path right $state_dir {1})" \
        --bind="left:transform($BASH $script_path left $state_dir)"
  ) || return 0
  [[ -n $result ]] || return 0

  format_selection "$mode" "$result"
}

script_path=$(realpath -- "$0")
case ${1-} in
  list) list_directories "$2" ;;
  right) navigate_right "$2" "$3" ;;
  left) navigate_left "$2" ;;
  label) print_label "$2" ;;
  *) browse "${1-}" ;;
esac
