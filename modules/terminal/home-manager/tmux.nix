{ wrappedTmux }:
{ ... }:

{
  programs.tmux = {
    enable = true;
    package = wrappedTmux;
  };
}
