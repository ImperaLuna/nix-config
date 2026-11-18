{ config, pkgs, ... }:

let
  theme = import ../../../_lib/theme.nix;
in
{
  xdg.configFile."atuin/themes/carbonfox.toml".text = ''
    [theme]
    name = "carbonfox"
    parent = "default"

    [colors]
    AlertInfo = "${theme.secondary}"
    AlertWarn = "${theme.warning}"
    AlertError = "${theme.error}"
    Annotation = "${theme.fgDim}"
    Base = "${theme.fg}"
    Guidance = "${theme.secondary}"
    Important = "${theme.primary}"
    Title = "${theme.primary}"
    Muted = "${theme.fgDim}"
    SyntaxCommand = "${theme.primary}"
    SyntaxFlag = "${theme.success}"
    SyntaxString = "${theme.warning}"
    SyntaxVariable = "${theme.secondary}"
    SyntaxOperator = "${theme.primary}"
    SyntaxComment = "${theme.fgDim}"
  '';


  # zsh writes no history file (_history.nix), so autosuggestions read the
  # newest successful command from atuin that starts with the typed prefix.
  # Set here because home-manager's strategy option only accepts built-ins;
  # the plugin reads the variable on each keystroke, so overriding it works.
  programs.zsh.initContent = ''
    ZSH_AUTOSUGGEST_STRATEGY=(atuin)
    _zsh_autosuggest_strategy_atuin() {
      typeset -g suggestion
      suggestion=$(${config.programs.atuin.package}/bin/atuin search \
        --cmd-only --limit 1 --search-mode prefix --exit 0 -- "$1" 2>/dev/null)
    }
  '';

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      theme = {
        name = "carbonfox";
      };
      auto_sync = false;
      store_failed = true;
      search_mode = "fuzzy";
      filter_mode = "global";
      filter_mode_shell_up_key_binding = "directory";
      style = "auto";
      inline_height = 20;
      enter_accept = false;
      show_preview = true;
      max_preview_height = 4;
    };
  };
}
