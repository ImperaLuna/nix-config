{ lib, config, ... }:

{
  imports = [
    ./headlamp/headlamp.nix
    ./python/python.nix
    ./obsidian/obsidian.nix
    ./bitwarden/bitwarden.nix
    ./proton-mail/proton-mail.nix
  ];

  options.modules.workstation.enable = lib.mkEnableOption "workstation tools";

  config = lib.mkIf config.modules.workstation.enable {
    modules = {
      headlamp.enable    = true;
      python.enable      = true;
      obsidian.enable    = true;
      bitwarden.enable   = true;
      proton-mail.enable = true;
    };
  };
}
