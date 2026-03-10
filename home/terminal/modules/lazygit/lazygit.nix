{ pkgs, lib, config, ... }:

{
  options.modules.lazygit.enable = lib.mkEnableOption "lazygit";

  config = lib.mkIf config.modules.lazygit.enable {
    home.packages = [ pkgs.lazygit ];

    xdg.configFile."lazygit/config.yml".source = ./assets/config.yml;
  };
}
