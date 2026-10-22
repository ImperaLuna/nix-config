{ ... }:

{
  programs.zsh.shellAliases = {
    cat = "command bat --style=plain --paging=never";
    ls = "eza --icons=always --color=always";
    install = "nix shell nixpkgs#";
    search = "nix search nixpkgs";
    # Run the Nova checkout you're in instead of the current bar; Ctrl+C or
    # closing the terminal brings the old bar back.
    nova-dev = "nix develop --quiet -c just run";
  };
}
