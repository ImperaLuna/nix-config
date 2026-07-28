{ ... }:

{
  imports = [
    ./_aliases.nix
    ./_functions.nix
    ./_highlighting.nix
  ];

  programs.zsh.enable = true;
}
