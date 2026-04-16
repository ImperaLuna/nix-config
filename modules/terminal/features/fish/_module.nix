{ pkgs, lib, ... }:

let
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
      set fish_cursor_default block
      set fish_cursor_insert line
      set fish_cursor_replace_one underscore
      set fish_cursor_visual block
      function _vi_cursor_color --on-variable fish_bind_mode
        switch $fish_bind_mode
          case insert
            printf '\e]12;#FD7014\a'
          case default
            printf '\e]12;#FD7014\a'
          case replace_one replace
            printf '\e]12;#D62828\a'
          case visual
            printf '\e]12;#412B6B\a'
        end
      end
      source ${pkgs.fishPlugins.fzf-fish}/share/fish/vendor_conf.d/fzf.fish
      set fish_function_path ${pkgs.fishPlugins.sponge}/share/fish/vendor_functions.d $fish_function_path
      source ${pkgs.fishPlugins.sponge}/share/fish/vendor_conf.d/sponge.fish


      set fish_cursor_default block
      set fish_cursor_insert line
      set fish_cursor_replace_one underscore
      set fish_cursor_visual block

      for mode in default insert
        bind --erase --preset --mode $mode \t 2>/dev/null
        bind --mode $mode \t _tab_complete_or_cd_menu
        bind --mode $mode ctrl-/ _fzf_search_commands_tldr
        bind --mode $mode ctrl-_ _fzf_search_commands_tldr
      end

      set -gx fzf_preview_dir_cmd eza --tree --level=2 --icons --color=always
      set fzf_diff_highlighter delta --paging=never --width=100
      set fzf_history_time_format %d-%m-%y
      set -gx FZF_DEFAULT_OPTS "\
      --layout=reverse \
      --color=bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8 \
      --color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
      --color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
      --color=selected-bg:#45475A \
      --color=border:#6C7086,label:#CDD6F4"

      set -g fish_color_normal cdd6f4
      set -g fish_color_command 89b4fa
      set -g fish_color_param f2cdcd
      set -g fish_color_keyword cba6f7
      set -g fish_color_quote a6e3a1
      set -g fish_color_redirection f5c2e7
      set -g fish_color_end fab387
      set -g fish_color_comment 7f849c
      set -g fish_color_error f38ba8
      set -g fish_color_gray 6c7086
      set -g fish_color_selection --background=313244
      set -g fish_color_search_match --background=313244
      set -g fish_color_option a6e3a1
      set -g fish_color_operator f5c2e7
      set -g fish_color_escape eba0ac
      set -g fish_color_autosuggestion 6c7086
      set -g fish_color_cancel f38ba8
      set -g fish_color_cwd f9e2af
      set -g fish_color_user 94e2d5
      set -g fish_color_host 89b4fa
      set -g fish_color_host_remote a6e3a1
      set -g fish_color_status f38ba8
      set -g fish_pager_color_progress 6c7086
      set -g fish_pager_color_prefix f5c2e7
      set -g fish_pager_color_completion cdd6f4
      set -g fish_pager_color_description 6c7086
    '';
  };
}
