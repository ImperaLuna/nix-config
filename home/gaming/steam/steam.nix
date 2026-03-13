{ lib, config, ... }:

{
  options.modules.steam.enable = lib.mkEnableOption "steam";

  config = lib.mkIf config.modules.steam.enable {
    xdg.desktopEntries.steam = {
      name = "Steam";
      comment = "Application for managing and playing games on Steam";
      exec = "steam %U";
      icon = "steam";
      terminal = false;
      categories = [ "Network" "FileTransfer" "Game" ];
      mimeType = [ "x-scheme-handler/steam" "x-scheme-handler/steamlink" ];
      settings = {
        PrefersNonDefaultGPU = "true";
        X-KDE-RunOnDiscreteGpu = "true";
      };
    };
  };
}
