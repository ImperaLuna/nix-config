{ lib, config, pkgs, ... }:

{
  imports = [
    ./ghostty/ghostty.nix
    ./zed/zed.nix
    ./obsidian/obsidian.nix
    ./bitwarden/bitwarden.nix
    ./zen/zen.nix
  ];

  options.modules.workstation.enable = lib.mkEnableOption "workstation tools";

  config = lib.mkIf config.modules.workstation.enable {
    home.packages = [ pkgs.python3 ];

    modules = {
      ghostty.enable   = true;
      zed.enable       = true;
      obsidian.enable  = true;
      bitwarden.enable = true;
      zen.enable       = true;
    };
  };
}
