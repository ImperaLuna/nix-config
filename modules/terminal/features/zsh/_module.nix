{ ... }:

{
  imports = [
    ./_aliases.nix
    ./_functions.nix
    ./_highlighting.nix
    ./_iris.nix
  ];

  programs.zsh.enable = true;
}
