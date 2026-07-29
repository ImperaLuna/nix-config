{ pkgs, ... }:

{
  # Remove once nixpkgs provides xwayland-satellite 0.8.2.
  nixpkgs.overlays = [
    (_final: prev: {
      xwayland-satellite = prev.xwayland-satellite.overrideAttrs (_old: {
        version = "0.8.2";
        src = prev.fetchFromGitHub {
          owner = "Supreeeme";
          repo = "xwayland-satellite";
          tag = "v0.8.2";
          hash = "sha256-Mb7jpqnrcYCfNSItIkkHpuR3YxWFxPuIBfcwNKlRBkk=";
        };
        cargoHash = "sha256-Saa3SRsQuY6u6pfBGezaEExOt/ReblnrG7pAXjA6Dk8=";
      });
    })
  ];

  programs.niri = {
    enable = true;
    useNautilus = false;
  };

  xdg.portal.config.niri = {
    "org.freedesktop.impl.portal.ScreenCast" = "gnome";
    Screenshot = [ "gnome" ];
  };

  environment.systemPackages = with pkgs; [
    xwayland-satellite
  ];

  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
}
