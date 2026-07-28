{ ... }:

let
  theme = import ../../../_lib/theme.nix;
in
{
  programs.zsh = {
    autosuggestion = {
      enable = true;
      highlight = "fg=${theme.fgDim}";
    };

    syntaxHighlighting = {
      enable = true;
      styles = {
        default = "fg=${theme.fg}";
        command = "fg=${theme.primary}";
        alias = "fg=${theme.primary}";
        function = "fg=${theme.secondary}";
        builtin = "fg=${theme.info}";
        precommand = "fg=${theme.info}";
        unknown-token = "fg=${theme.error}";
        reserved-word = "fg=${theme.primary}";
        commandseparator = "fg=${theme.primary}";
        redirection = "fg=${theme.primary}";
        path = "fg=${theme.fg},underline";
        path_prefix = "fg=${theme.fg},underline";
        globbing = "fg=${theme.secondary}";
        single-hyphen-option = "fg=${theme.success}";
        double-hyphen-option = "fg=${theme.success}";
        single-quoted-argument = "fg=${theme.warning}";
        double-quoted-argument = "fg=${theme.warning}";
        dollar-quoted-argument = "fg=${theme.warning}";
        back-quoted-argument = "fg=${theme.warning}";
        dollar-double-quoted-argument = "fg=${theme.warning}";
        assign = "fg=${theme.info}";
        comment = "fg=${theme.fgDim},italic";
        history-expansion = "fg=${theme.info}";
        command-substitution = "fg=${theme.info}";
      };
    };
  };
}
