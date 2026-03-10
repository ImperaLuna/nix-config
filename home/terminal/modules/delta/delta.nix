{ lib, config, ... }:

{
  options.modules.delta.enable = lib.mkEnableOption "delta";

  config = lib.mkIf config.modules.delta.enable {
    programs.delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        features = "catppuccin-mocha";
        navigate = true;
        side-by-side = true;
      };
    };

    programs.git.includes = [
      { path = ./assets/catppuccin.gitconfig; }
    ];
  };
}
