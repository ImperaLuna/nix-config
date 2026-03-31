{ lib, config, ... }:

{
  options.modules.remote-access.enable = lib.mkEnableOption "remote access";

  config = lib.mkIf config.modules.remote-access.enable {
    services.tailscale = {
      enable = true;
      openFirewall = true;
    };

    services.openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };
  };
}
