{ pkgs }:

pkgs.writeShellApplication {
  name = "fzf-cd-browser";
  runtimeInputs = with pkgs; [
    coreutils
    eza
    findutils
    fzf
  ];
  text = builtins.readFile ./_fzf-cd-browser.sh;
}
