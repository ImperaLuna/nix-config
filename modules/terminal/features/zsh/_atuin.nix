{ ... }:

let
  theme = import ../../../_lib/theme.nix;
in
{
  xdg.configFile."atuin/themes/carbonfox.toml".text = ''
    [theme]
    name = "carbonfox"
    parent = "default"

    [colors]
    AlertInfo = "${theme.info}"
    AlertWarn = "${theme.warning}"
    AlertError = "${theme.error}"
    Annotation = "${theme.fgDim}"
    Base = "${theme.fg}"
    Guidance = "${theme.info}"
    Important = "${theme.primary}"
    Title = "${theme.primary}"
    Muted = "${theme.fgDim}"
    SyntaxCommand = "${theme.primary}"
    SyntaxFlag = "${theme.success}"
    SyntaxString = "${theme.warning}"
    SyntaxVariable = "${theme.info}"
    SyntaxOperator = "${theme.primary}"
    SyntaxComment = "${theme.fgDim}"
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
