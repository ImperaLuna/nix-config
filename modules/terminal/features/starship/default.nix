{ ... }:

{
  flake.modules.homeManager.terminal-feature-starship = {
    programs.starship = {
      enable = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };

    xdg.configFile."starship.toml".source = ./assets/starship.toml;
  };
}
