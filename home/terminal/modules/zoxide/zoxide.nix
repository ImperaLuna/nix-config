{ lib, config, ... }:

{
  options.modules.zoxide.enable = lib.mkEnableOption "zoxide";

  config = lib.mkIf config.modules.zoxide.enable {
    programs.zoxide = {
      enable = true;
      enableFishIntegration = true;
      options = [ "--cmd" "cd" ];
    };
  };
}
