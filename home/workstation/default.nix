{ lib, config, ... }:

{
  imports = [
    ./ghostty/ghostty.nix
    ./python/python.nix
    ./zed/zed.nix
    ./obsidian/obsidian.nix
    ./bitwarden/bitwarden.nix
  ];

  options.modules.workstation.enable = lib.mkEnableOption "workstation tools";

  config = lib.mkIf config.modules.workstation.enable {
    modules = {
      ghostty.enable   = true;
      python.enable    = true;
      zed.enable       = true;
      obsidian.enable  = true;
      bitwarden.enable = true;
    };
  };
}
