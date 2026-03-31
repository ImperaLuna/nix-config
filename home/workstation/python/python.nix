{ pkgs, lib, config, ... }:

{
  options.modules.python.enable = lib.mkEnableOption "python tools";

  config = lib.mkIf config.modules.python.enable {
    home.packages = with pkgs; [
      python3
      uv
    ];
  };
}
