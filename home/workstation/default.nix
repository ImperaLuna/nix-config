{ lib, config, ... }:

{
  imports = [
    ./ghostty/ghostty.nix
    ./headlamp/headlamp.nix
    ./python/python.nix
    ./zed/zed.nix
    ./obsidian/obsidian.nix
    ./bitwarden/bitwarden.nix
    ./proton-mail/proton-mail.nix
  ];

  options.modules.workstation.enable = lib.mkEnableOption "workstation tools";

  config = lib.mkIf config.modules.workstation.enable {
    modules = {
      ghostty.enable   = true;
      headlamp.enable  = true;
      python.enable    = true;
      zed.enable       = true;
      obsidian.enable  = true;
      bitwarden.enable = true;
      proton-mail.enable = true;
    };
  };
}
