{ ... }:

{
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };

  xdg.configFile."starship.toml".source =
    ../../../home/terminal/modules/starship/assets/starship.toml;
}
