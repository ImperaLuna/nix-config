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
    source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
  '';

  home.packages = [ pkgs.fzf ];
}
