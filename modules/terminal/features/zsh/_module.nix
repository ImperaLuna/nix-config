{ pkgs, lib, ... }:

{
  imports = [
    ./_aliases.nix
    ./_functions.nix
    ./_highlighting.nix
    ./_history.nix
    ./_atuin.nix
  ];

  programs.zsh.enable = true;
  programs.zsh.enableCompletion = true;

  # fzf-tab must load after compinit and before autosuggestions.
  programs.zsh.initContent = lib.mkOrder 650 ''
    bindkey -e
    zmodload zsh/terminfo
    if [[ -n "''${terminfo[kdch1]}" ]]; then
      bindkey "''${terminfo[kdch1]}" delete-char
    fi

    source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh

    # Include dotfiles in native completion and therefore in fzf-tab's menu.
    # Unlike GLOB_DOTS, this does not make ordinary globs such as `rm *` match them.
    zstyle ':completion:*' file-patterns \
      '%p(D):globbed-files *(D-/):directories' \
      '*(D):all-files'

    # Zsh's completion definitions provide the candidates; fzf-tab is only the
    # universal presenter. This covers paths, options, subcommands, hosts, etc.
    zstyle ':fzf-tab:*' fzf-flags \
      --height=100% \
      --preview-window=right:60% \
      --header='TAB navigate  CTRL-SPACE mark/unmark  ENTER insert  ESC cancel'
    zstyle ':fzf-tab:complete:*:*' fzf-preview \
      'if [[ -n $realpath && -d $realpath ]]; then ${pkgs.eza}/bin/eza --tree --level=2 --color=always --icons=always -- "$realpath"; elif [[ -n $realpath && -f $realpath ]]; then ${pkgs.bat}/bin/bat --color=always --style=numbers --line-range=:500 -- "$realpath"; elif [[ -n $desc && $desc != $word ]]; then print -r -- "$desc"; fi'

    bindkey -M emacs '^Z' undo
    bindkey -M viins '^Z' undo
  '';

  home.packages = [ pkgs.fzf ];
}
