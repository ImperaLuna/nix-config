{ ... }:

{
  # Atuin is the only persistent history store (see _atuin.nix). Zsh keeps
  # history in memory for !!, !$ and fc, but never writes a file: on WSL an
  # unclean VM stop left NUL bytes in ~/.zsh_history, and two stores drift.
  programs.zsh.history = {
    save = 0;
    share = false;
    ignoreAllDups = true;
    saveNoDups = true;
  };
}
