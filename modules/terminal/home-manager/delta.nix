{ ... }:

{
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
    { path = ../../../home/terminal/modules/delta/assets/catppuccin.gitconfig; }
  ];
}
