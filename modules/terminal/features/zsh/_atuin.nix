{ pkgs, ... }:

let
  theme = import ../../../_lib/theme.nix;
  atuin = pkgs.atuin.overrideAttrs (_: rec {
    version = "18.18.0";
    src = pkgs.fetchFromGitHub {
      owner = "atuinsh";
      repo = "atuin";
      tag = "v18.18.0";
      hash = "sha256-o20MwzWItvKcUIwrfxY60v2jqLnqLRbQ9lIevQWgVPI=";
    };
    cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
      pname = "atuin";
      inherit version src;
      hash = "sha256-IoOIpcobVcmQBzDiSsT3WvVW6UiRpZ6NWE0GlzDLlYk=";
    };
  });
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


  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    # Remove this override once nixpkgs provides Atuin 18.18 or newer.
    package = atuin;

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
