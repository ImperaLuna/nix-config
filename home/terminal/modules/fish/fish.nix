{ pkgs, lib, config, ... }:

let
  fifc = pkgs.fishPlugins.fifc.overrideAttrs (_: {
    src = pkgs.fetchFromGitHub {
      owner = "gazorby";
      repo = "fifc";
      rev = "a01650cd432becdc6e36feeff5e8d657bd7ee84a";
      hash = "sha256-Ynb0Yd5EMoz7tXwqF8NNKqCGbzTZn/CwLsZRQXIAVp4=";
    };
  });

  fish-abbreviation-tips = pkgs.fishPlugins.buildFishPlugin {
    pname = "fish-abbreviation-tips";
    version = "unstable-2024";
    src = pkgs.fetchFromGitHub {
      owner = "gazorby";
      repo = "fish-abbreviation-tips";
      rev = "8ed76a62bb044ba4ad8e3e6832640178880df485";
      hash = "sha256-F1t81VliD+v6WEWqj1c1ehFBXzqLyumx5vV46s/FZRU=";
    };
  };
in

{
  imports = [ ./fifc.nix ];

  options.modules.fish.enable = lib.mkEnableOption "fish";

  config = lib.mkIf config.modules.fish.enable {
    programs.fish = {
      enable = true;
      shellInit = ''
        set fish_function_path ${fifc}/share/fish/vendor_functions.d $fish_function_path
        set fish_function_path ${pkgs.fishPlugins.fzf-fish}/share/fish/vendor_functions.d $fish_function_path
        source ${fifc}/share/fish/vendor_conf.d/fifc.fish

        # Custom fifc preview rules — registered in shellInit so they run in ALL fish
        # processes, including the non-interactive fzf preview subprocess.
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
      '';
      interactiveShellInit = lib.mkBefore ''
        set -g fish_greeting
        source ${pkgs.fishPlugins.fzf-fish}/share/fish/vendor_conf.d/fzf.fish
        set fish_function_path ${pkgs.fishPlugins.sponge}/share/fish/vendor_functions.d $fish_function_path
        source ${pkgs.fishPlugins.sponge}/share/fish/vendor_conf.d/sponge.fish
        set fish_function_path ${pkgs.fishPlugins.fish-you-should-use}/share/fish/vendor_functions.d $fish_function_path
        source ${pkgs.fishPlugins.fish-you-should-use}/share/fish/vendor_conf.d/you_should_use.fish
        set fish_function_path ${fish-abbreviation-tips}/share/fish/vendor_functions.d $fish_function_path
        source ${fish-abbreviation-tips}/share/fish/vendor_conf.d/abbr_tips.fish
        emit abbr_tips_install

        # FZF configuration
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

        # Catppuccin Mocha theme
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
      functions._fzf_command_help_preview = ''
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
      functions._fzf_search_commands_tldr = ''
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
      functions.fish_user_key_bindings = ''
        for mode in default insert
          bind --mode $mode \t _fifc
          bind --mode $mode ctrl-/ _fzf_search_commands_tldr
          bind --mode $mode ctrl-_ _fzf_search_commands_tldr
        end
      '';
      shellAliases = {
        cat = "bat";
        ls = "eza --icons --color=always";
      };
      shellAbbrs = {
        build = "sudo nixos-rebuild switch --flake ~/nix-config#nixos";
        batn = "cat --style=full --paging=auto";
        gs = "git status";
      };
    };
  };
}
