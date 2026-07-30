#!/usr/bin/env bash

set -euo pipefail

find_entries() {
  local directory=$1
  local browse_mode=$2

  if [[ $browse_mode == directories ]]; then
    find "$directory" -mindepth 1 -maxdepth 1 -xtype d ! -name '.*' -print0 | LC_ALL=C sort -z
  else
    find "$directory" -mindepth 1 -maxdepth 1 -xtype d ! -name '.*' -print0 | LC_ALL=C sort -z
    find "$directory" -mindepth 1 -maxdepth 1 ! -xtype d ! -name '.*' -print0 | LC_ALL=C sort -z
  fi
}

list_entries() {
  local state_dir=$1
  local base browse_mode candidate name
  local index
  local -a candidates names displays

  base=$(<"$state_dir/base")
  browse_mode=$(<"$state_dir/mode")
  while IFS= read -r -d '' candidate; do
    candidates+=("$candidate")
    names+=("${candidate##*/}")
  done < <(find_entries "$base" "$browse_mode")

  if (( ${#candidates[@]} == 0 )); then
    name=${base##*/}
    [[ -n $name ]] || name=/
    printf '%s\t%s/\n' "$base" "$name"
    return
  fi

  mapfile -t displays < <(
    cd -- "$base"
    eza --oneline --list-dirs --sort=none --color=always --icons=always --classify=always -- "${names[@]}"
  )
  if (( ${#displays[@]} != ${#candidates[@]} )); then
    displays=("${names[@]}")
  fi

  for ((index = 0; index < ${#candidates[@]}; index++)); do
    printf '%s\t%s\n' "${candidates[index]}" "${displays[index]}"
  done
}

has_browsable_entry() {
  local directory=$1
  local browse_mode=$2
  local candidate

  while IFS= read -r -d '' candidate; do
    return 0
  done < <(find_entries "$directory" "$browse_mode")
  return 1
}

entry_position() {
  local directory=$1
  local target=$2
  local browse_mode=$3
  local candidate
  local position=0

  while IFS= read -r -d '' candidate; do
    ((position += 1))
    if [[ $candidate == "$target" ]]; then
      printf '%d\n' "$position"
      return
    fi
  done < <(find_entries "$directory" "$browse_mode")

  printf '1\n'
}

remember_selection() {
  local state_dir=$1
  local directory=$2
  local selected=$3
  local history_file="$state_dir/history"
  local temporary_file="$state_dir/history.new"
  local recorded_directory recorded_selection

  [[ -n $selected ]] || return
  : > "$temporary_file"
  if [[ -f $history_file ]]; then
    while IFS=$'\t' read -r recorded_directory recorded_selection; do
      [[ $recorded_directory == "$directory" ]] ||
        printf '%s\t%s\n' "$recorded_directory" "$recorded_selection" >> "$temporary_file"
    done < "$history_file"
  fi
  printf '%s\t%s\n' "$directory" "$selected" >> "$temporary_file"
  mv -- "$temporary_file" "$history_file"
}

remembered_selection() {
  local state_dir=$1
  local directory=$2
  local history_file="$state_dir/history"
  local recorded_directory recorded_selection

  if [[ -f $history_file ]]; then
    while IFS=$'\t' read -r recorded_directory recorded_selection; do
      if [[ $recorded_directory == "$directory" ]]; then
        printf '%s\n' "$recorded_selection"
        return
      fi
    done < "$history_file"
  fi
}

reload_action() {
  local state_dir=$1
  local shell_path=$2
  local script_path=$3
  local position=$4

  printf 'change-query()+reload-sync(%s %s list %s)+wait+pos(%d)+transform-list-label(%s %s label %s)\n' \
    "$shell_path" "$script_path" "$state_dir" "$position" "$shell_path" "$script_path" "$state_dir"
}

navigate_right() {
  local state_dir=$1
  local selected=$2
  local base browse_mode parent remembered position

  base=$(<"$state_dir/base")
  browse_mode=$(<"$state_dir/mode")
  parent=$(dirname -- "$selected")
  if [[ ! -d $selected || $selected == "$base" || $parent != "$base" ]] ||
    ! has_browsable_entry "$selected" "$browse_mode"; then
    printf 'ignore\n'
    return
  fi

  remember_selection "$state_dir" "$base" "$selected"
  printf '%s\n' "$selected" > "$state_dir/base"
  remembered=$(remembered_selection "$state_dir" "$selected")
  if [[ -n $remembered ]]; then
    position=$(entry_position "$selected" "$remembered" "$browse_mode")
  else
    position=1
  fi
  reload_action "$state_dir" "$BASH" "$script_path" "$position"
}

navigate_left() {
  local state_dir=$1
  local selected=$2
  local base browse_mode parent position

  base=$(<"$state_dir/base")
  browse_mode=$(<"$state_dir/mode")
  if [[ $base == / ]]; then
    printf 'ignore\n'
    return
  fi

  remember_selection "$state_dir" "$base" "$selected"
  parent=$(dirname -- "$base")
  remember_selection "$state_dir" "$parent" "$base"
  position=$(entry_position "$parent" "$base" "$browse_mode")
  printf '%s\n' "$parent" > "$state_dir/base"
  reload_action "$state_dir" "$BASH" "$script_path" "$position"
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
  local path_mode=$1
  local selected=$2

  case $path_mode in
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
  local browse_mode=$1
  local token=${2-}
  local path base prefix path_mode state_dir result selected header
  local -a selection_args

  case $token in
    '~') path=$HOME; path_mode=home ;;
    \~/*) path="$HOME/${token:2}"; path_mode=home ;;
    /*) path=$token; path_mode=absolute ;;
    *) path=$token; path_mode=relative ;;
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
  printf '%s\n' "$browse_mode" > "$state_dir/mode"

  header='←/→ navigate  ENTER insert  ESC cancel'
  if [[ $browse_mode == paths ]]; then
    header='TAB mark/unmark  ←/→ navigate  ENTER insert  ESC cancel'
    selection_args=(--multi --marker='✓' --bind='tab:toggle+down')
  fi

  result=$(
    "$BASH" "$script_path" list "$state_dir" |
      fzf \
        "${selection_args[@]}" \
        --ansi \
        --with-shell="$BASH -c" \
        --delimiter=$'\t' \
        --with-nth=2 \
        --accept-nth=1 \
        --query="$prefix" \
        --layout=reverse \
        --header="$header" \
        --list-label="$("$BASH" "$script_path" label "$state_dir")" \
        --preview="'$BASH' -c 'if [[ -d \$1 ]]; then eza --tree --level=2 --color=always --icons=always -- \"\$1\"; else bat --color=always --style=numbers --line-range=:500 -- \"\$1\"; fi' _ {1}" \
        --preview-window='right:60%' \
        --bind="right:transform($BASH $script_path right $state_dir {1})" \
        --bind="left:transform($BASH $script_path left $state_dir {1})"
  ) || return 0
  [[ -n $result ]] || return 0

  while IFS= read -r selected; do
    [[ -n $selected ]] && format_selection "$path_mode" "$selected"
  done <<< "$result"
}

script_path=$(realpath -- "$0")
case ${1-} in
  list) list_entries "$2" ;;
  right) navigate_right "$2" "$3" ;;
  left) navigate_left "$2" "$3" ;;
  label) print_label "$2" ;;
  directories | paths) browse "$1" "${2-}" ;;
  *) exit 2 ;;
esac
