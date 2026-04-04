{ ... }:

{
  flake.modules.homeManager.terminal-feature-delta = {
    programs.delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        features = "catppuccin-mocha";
        navigate = true;
        side-by-side = false;
      };
    };

    programs.git.includes = [
      { path = ./assets/catppuccin.gitconfig; }
    ];
  };
}
