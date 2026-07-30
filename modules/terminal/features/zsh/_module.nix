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
    if [[ -f "$HOME/.claude/start-jira-tunnel-login.sh" ]]; then
      ${pkgs.bash}/bin/bash "$HOME/.claude/start-jira-tunnel-login.sh"
    fi

    zmodload zsh/terminfo
    if [[ -n "''${terminfo[kdch1]}" ]]; then
      bindkey "''${terminfo[kdch1]}" delete-char
    fi

    source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh

    bindkey -M emacs '^Z' undo
    bindkey -M viins '^Z' undo
  '';

  home.packages = [ pkgs.fzf ];
}
