{ inputs, ... }:

{
  flake.modules.homeManager.desktop-feature-nova = { pkgs, lib, ... }:
    {
      # Nova's own module: Nova, its user unit, and the packages of the features that are on. Turn features on or off here, e.g. programs.nova.features.wallpaper-engine.enable = true;
      imports = [ inputs.nova-rebuild.homeManagerModules.default ];
      programs.nova.enable = true;

      home.packages = [
        pkgs.adwaita-icon-theme
        pkgs.hicolor-icon-theme
        pkgs.kdePackages.breeze-icons
        pkgs.nixos-icons
      ];

      systemd.user.services.xembedsniproxy = {
        Unit = {
          Description = "Convert XEmbed tray icons to StatusNotifierItems";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = lib.getExe' pkgs.kdePackages.plasma-workspace "xembedsniproxy";
          Restart = "on-failure";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    };
}
