{ ... }:
let
  theme = import ../../_lib/theme.nix;
in

{
  flake.modules.homeManager.terminal-feature-fzf = { pkgs, ... }: {
    home.packages = [ pkgs.fzf ];
    home.sessionVariables.FZF_DEFAULT_OPTS = ''
      --layout=reverse
      --color=bg:${theme.bg},bg+:${theme.primary},spinner:${theme.info},hl:${theme.primary}
      --color=fg:${theme.fg},fg+:${theme.bg},header:${theme.primary},info:${theme.fg},pointer:${theme.bg}
      --color=marker:${theme.bg},prompt:${theme.primary},hl+:${theme.bg}
      --color=selected-bg:${theme.primary}
      --color=border:${theme.bgAlt},label:${theme.fg}
    '';
  };
}
