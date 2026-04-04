{ ... }:

{
  programs.fish.functions = {
    _fifc_parse_complist = ''
      command cat $_fifc_complist_path \
          | string unescape \
          | uniq \
          | awk -F '\t' '{ print $1 }'
    '';
    _tab_complete_or_cd_menu = ''
      set -l line (commandline --cut-at-cursor)
      set -l token (commandline --current-token)

      if string match -qr '^\S+$' -- "$line"
          _fzf_search_commands_tldr
          return
      end

      if not string match -qr '^cd(\s|$)' -- "$line"
          _fifc
          return
      end

      set -l path (_fifc_expand_tilde "$token")
      set -l base_dir .
      set -l prefix

      if string match --quiet -- '*/' "$token"; or test -d "$path"
          set base_dir "$path"
      else if test -n "$path"
          set base_dir (path dirname -- "$path")
          set prefix (path basename -- "$path")
      end

      test -d "$base_dir"; or return

      set -l candidates
      if type -q fd
          set candidates (
              fd --max-depth 1 --type d "^$prefix" "$base_dir" 2>/dev/null \
                  | string replace --regex '^\\./' ""
          )
      else
          for dir in (find "$base_dir" -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
              set -l trimmed (string replace --regex '^\\./' "" -- "$dir")
              set -l name (path basename -- "$trimmed")
              string match --quiet -- "$prefix*" -- "$name"; and set -a candidates "$trimmed"
          end
      end

      if test (count $candidates) -eq 0
          commandline --function complete
          return
      end

      set -l selected (
          printf '%s\n' $candidates \
              | fzf \
                  --select-1 \
                  --exit-0 \
                  --reverse \
                  --ansi \
                  --query "$prefix" \
                  --preview 'eza --tree --level=2 --color=always --icons {}'
      )

      if test -n "$selected"
          commandline --replace --current-token -- "$selected"
          commandline --function repaint
      end
    '';
    _fifc_source_cd_directories = ''
      set -l token (string unescape -- $fifc_token)
      set -l path (_fifc_expand_tilde "$token")
      set -l base_dir .
      set -l prefix

      if string match --quiet -- '*/' "$token"; or test -d "$path"
          set base_dir "$path"
      else if test -n "$path"
          set base_dir (path dirname -- "$path")
          set prefix (path basename -- "$path")
      end

      test -d "$base_dir"; or return

      if type -q fd
          fd --max-depth 1 --type d "^$prefix" "$base_dir" 2>/dev/null \
              | string replace --regex '^\\./' ""
      else
          find "$base_dir" -mindepth 1 -maxdepth 1 -type d 2>/dev/null \
              | while read -l dir
                    set -l trimmed (string replace --regex '^\\./' "" -- "$dir")
                    set -l name (path basename -- "$trimmed")
                    string match --quiet -- "$prefix*" -- "$name"; and echo "$trimmed"
                end
      end
    '';
    _fifc_preview_cmd = ''
      if type -q tldr
          tldr $fifc_candidate 2>/dev/null | bat --paging=never --language=markdown; or man $fifc_candidate 2>/dev/null | bat --paging=never --language=markdown $fifc_bat_opts
      else if type -q bat
          man $fifc_candidate 2>/dev/null | bat --paging=never --language=markdown $fifc_bat_opts
      else
          man $fifc_candidate 2>/dev/null
      end
    '';
    _fzf_history_delete = ''
      set -l time_prefix_regex '^.*? │ '
      while read -lz item
          set -l first_line (string split -- \n $item)[1]
          set -l cmd_start (string replace --regex $time_prefix_regex "" -- $first_line)
          if test -z "$cmd_start"
              continue
          end
          builtin history --null | while read -lz entry
              if test (string split -- \n $entry)[1] = $cmd_start
                  builtin history delete --exact --case-sensitive -- $entry
                  break
              end
          end
      end
      builtin history save
    '';
    _fzf_search_history = ''
      if test -z "$fish_private_mode"
          builtin history merge
      end

      if not set --query fzf_history_time_format
          set -f fzf_history_time_format "%m-%d %H:%M:%S"
      end

      set -f time_prefix_regex '^.*? │ '
      set -f time_fmt $fzf_history_time_format

      set -f commands_selected (
          builtin history --null --show-time="$fzf_history_time_format │ " |
          _fzf_wrapper --read0 \
              --print0 \
              --multi \
              --scheme=history \
              --prompt="History> " \
              --query=(commandline) \
              --preview="string replace --regex '$time_prefix_regex' \"\" -- {} | fish_indent --ansi" \
              --preview-window="bottom:3:wrap" \
              --header="TAB: select multiple  CTRL-DEL: delete selected" \
              --bind "ctrl-delete:execute(_fzf_history_delete < {+f})+reload(builtin history merge 2>/dev/null; builtin history --null --show-time=\"$time_fmt │ \" )" \
              $fzf_history_opts |
          string split0 |
          string replace --regex $time_prefix_regex ""
      )

      if test $status -eq 0
          commandline --replace -- $commands_selected
      end

      commandline --function repaint
    '';
    _fzf_command_help_preview = ''
      set -l cmd $argv[1]
      set -l mode tldr

      if set -q FZF_COMMAND_HELP_MODE_FILE; and test -f "$FZF_COMMAND_HELP_MODE_FILE"
          set mode (string trim < "$FZF_COMMAND_HELP_MODE_FILE")
      end

      if test "$mode" = tldr
          if type -q tldr
              tldr "$cmd" 2>/dev/null | bat --paging=never --language=markdown
              if test $pipestatus[1] -eq 0
                  return 0
              end
          end
      end

      if type -q bat
          man "$cmd" 2>/dev/null | bat --paging=never --language=man
      else
          man "$cmd" 2>/dev/null
      end
    '';
    _fzf_search_commands_tldr = ''
      set -f token (commandline --current-token)
      set -lx FZF_COMMAND_HELP_MODE_FILE (mktemp)
      printf 'tldr\n' > "$FZF_COMMAND_HELP_MODE_FILE"

      set -f selected (complete -C "" 2>/dev/null \
          | _fzf_wrapper \
              --query "$token" \
              --exact \
              --delimiter '\t' \
              --nth '1' \
              --with-nth '1' \
              --preview '_fzf_command_help_preview {1}' \
              --preview-window 'right:60%' \
              --preview-label ' TLDR ' \
              --prompt "Commands> " \
              --header 'left: TLDR  right: MAN' \
              --bind 'left:execute-silent(printf "tldr\n" > "$FZF_COMMAND_HELP_MODE_FILE")+change-preview-label( TLDR )+refresh-preview' \
              --bind 'right:execute-silent(printf "man\n" > "$FZF_COMMAND_HELP_MODE_FILE")+change-preview-label( MAN )+refresh-preview' \
              --ansi)

      if test $status -eq 0 -a -n "$selected"
          set -f cmd (string split \t "$selected")[1]
          commandline --current-token --replace -- $cmd
      end

      rm -f "$FZF_COMMAND_HELP_MODE_FILE"
      commandline --function repaint
    '';
    ssh = ''
      if test "$TERM" = "xterm-ghostty"
          env TERM=xterm-256color ssh $argv
      else
          command ssh $argv
      end
    '';
  };
}
