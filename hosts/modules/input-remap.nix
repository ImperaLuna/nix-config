{ lib, config, ... }:

{
  options.modules.input-remap.enable = lib.mkEnableOption "input remapping support";

  config = lib.mkIf config.modules.input-remap.enable {
    boot.kernelModules = [ "uinput" ];
    services.udev.extraRules = ''
      KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"
    '';
  };
}
