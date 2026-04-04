{ ... }:

{
  flake.modules.homeManager.terminal-feature-starship = {
    programs.starship = {
      enable = true;
      enableFishIntegration = true;
    };

    xdg.configFile."starship.toml".source = ./assets/starship.toml;
  };
}
