{ pkgs, lib, ... }:

let
  theme = import ../../../_lib/theme.nix;

  fifc = pkgs.fishPlugins.fifc.overrideAttrs (_: {
    src = pkgs.fetchFromGitHub {
      owner = "gazorby";
      repo = "fifc";
      rev = "a01650cd432becdc6e36feeff5e8d657bd7ee84a";
      hash = "sha256-Ynb0Yd5EMoz7tXwqF8NNKqCGbzTZn/CwLsZRQXIAVp4=";
    };
  });

in
{
  imports = [
    ./_functions.nix
    ./_aliases.nix
    ./_env.nix
  ];

  programs.fish = {
    enable = true;
    shellInit = ''
      if test -f ~/.kube/config
        set -gx KUBECONFIG ~/.kube/config
      end

      set fish_function_path ${fifc}/share/fish/vendor_functions.d $fish_function_path
      set fish_function_path ${pkgs.fishPlugins.fzf-fish}/share/fish/vendor_functions.d $fish_function_path
      set fish_function_path $__fish_config_dir/functions $fish_function_path
      source ${fifc}/share/fish/vendor_conf.d/fifc.fish

      fifc \
          -n 'string match -qr "^git" $fifc_commandline' \
          -p 'git log --oneline --color=always $fifc_candidate 2>/dev/null; or git show --stat --color=always $fifc_candidate 2>/dev/null'
      fifc \
          -n 'string match -qr "^systemctl" $fifc_commandline' \
          -p 'systemctl status $fifc_candidate 2>/dev/null; printf "\n---\n"; tldr $fifc_candidate 2>/dev/null'
      fifc \
          -n 'test -d "$fifc_candidate"' \
          -p 'eza --tree --level=2 --color=always --icons "$fifc_candidate"' \
          -O 1
      fifc \
          -n 'string match -qr "^cd\\s" -- $fifc_commandline; or test "$fifc_commandline" = cd' \
          -s _fifc_source_cd_directories \
          -p 'eza --tree --level=2 --color=always --icons "$fifc_candidate"' \
          -O 2
    '';

    interactiveShellInit = lib.mkBefore ''
      set -g fish_greeting
      fish_vi_key_bindings
      function fish_mode_prompt; end
      function _vi_cursor_color --on-variable fish_bind_mode
        switch $fish_bind_mode
          case insert
            printf '\e]12;${theme.primary}\a'
          case default
            printf '\e]12;${theme.primary}\a'
          case replace_one replace
            printf '\e]12;${theme.error}\a'
          case visual
            printf '\e]12;${theme.primary}\a'
        end
      end
      source ${pkgs.fishPlugins.fzf-fish}/share/fish/vendor_conf.d/fzf.fish
      set fish_function_path ${pkgs.fishPlugins.sponge}/share/fish/vendor_functions.d $fish_function_path
      source ${pkgs.fishPlugins.sponge}/share/fish/vendor_conf.d/sponge.fish

      for mode in default insert
        bind --erase --preset --mode $mode \t 2>/dev/null
        bind --mode $mode \t _tab_complete_or_cd_menu
        bind --mode $mode ctrl-/ _fzf_search_commands_tldr
      end

      set -gx fzf_preview_dir_cmd eza --tree --level=2 --icons --color=always
      set fzf_diff_highlighter delta --paging=never --width=100
      set fzf_history_time_format %d-%m-%y
      set -gx FZF_DEFAULT_OPTS "\
      --layout=reverse \
      --color=bg:${theme.bg},bg+:${theme.primary},spinner:${theme.info},hl:${theme.primary} \
      --color=fg:${theme.fg},fg+:${theme.bg},header:${theme.primary},info:${theme.fg},pointer:${theme.bg} \
      --color=marker:${theme.bg},prompt:${theme.primary},hl+:${theme.bg} \
      --color=selected-bg:${theme.primary} \
      --color=border:${theme.bgAlt},label:${theme.fg}"

      set -g fish_color_normal ${builtins.substring 1 6 theme.fg}
      set -g fish_color_command ${builtins.substring 1 6 theme.primary}
      set -g fish_color_param ${builtins.substring 1 6 theme.fg}
      set -g fish_color_keyword ${builtins.substring 1 6 theme.primary}
      set -g fish_color_quote ${builtins.substring 1 6 theme.success}
      set -g fish_color_redirection ${builtins.substring 1 6 theme.primary}
      set -g fish_color_end ${builtins.substring 1 6 theme.warning}
      set -g fish_color_comment ${builtins.substring 1 6 theme.fgDim}
      set -g fish_color_error ${builtins.substring 1 6 theme.error}
      set -g fish_color_gray ${builtins.substring 1 6 theme.fgAlt}
      set -g fish_color_selection ${builtins.substring 1 6 theme.bg} --background=${builtins.substring 1 6 theme.primary}
      set -g fish_color_search_match ${builtins.substring 1 6 theme.bg} --background=${builtins.substring 1 6 theme.primary}
      set -g fish_color_option ${builtins.substring 1 6 theme.success}
      set -g fish_color_operator ${builtins.substring 1 6 theme.primary}
      set -g fish_color_escape ${builtins.substring 1 6 theme.info}
      set -g fish_color_autosuggestion ${builtins.substring 1 6 theme.fgDim}
      set -g fish_color_cancel ${builtins.substring 1 6 theme.error}
      set -g fish_color_cwd ${builtins.substring 1 6 theme.primary}
      set -g fish_color_user ${builtins.substring 1 6 theme.info}
      set -g fish_color_host ${builtins.substring 1 6 theme.primary}
      set -g fish_color_host_remote ${builtins.substring 1 6 theme.success}
      set -g fish_color_status ${builtins.substring 1 6 theme.error}
      set -g fish_pager_color_progress ${builtins.substring 1 6 theme.fgAlt}
      set -g fish_pager_color_prefix ${builtins.substring 1 6 theme.primary}
      set -g fish_pager_color_completion ${builtins.substring 1 6 theme.fg}
      set -g fish_pager_color_description ${builtins.substring 1 6 theme.fgAlt}
      set -g fish_pager_color_selected_background --background=${builtins.substring 1 6 theme.primary}
      set -g fish_pager_color_selected_prefix ${builtins.substring 1 6 theme.bg} --background=${builtins.substring 1 6 theme.primary}
      set -g fish_pager_color_selected_completion ${builtins.substring 1 6 theme.bg} --background=${builtins.substring 1 6 theme.primary}
      set -g fish_pager_color_selected_description ${builtins.substring 1 6 theme.bg} --background=${builtins.substring 1 6 theme.primary}
    '';
  };
}
