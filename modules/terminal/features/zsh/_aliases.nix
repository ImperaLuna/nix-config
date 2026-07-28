{ ... }:

{
  programs.zsh.shellAliases = {
    cat = "command bat --style=plain --paging=never";
    ls = "eza --icons=always --color=always";
    install = "nix shell nixpkgs#";
    search = "nix search nixpkgs";
  };
}
