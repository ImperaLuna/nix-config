{ lib, config, ... }:

{
  options.modules.starship.enable = lib.mkEnableOption "starship";

  config = lib.mkIf config.modules.starship.enable {
    programs.starship = {
      enable = true;
      enableFishIntegration = true;
    };

    xdg.configFile."starship.toml".source = ./assets/starship.toml;
  };
}
