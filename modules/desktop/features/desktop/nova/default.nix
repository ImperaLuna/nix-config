{ ... }:

{
  # What Nova's session needs beside Nova itself. Nova comes from its NixOS
  # module on RyzenShine (modules/__hosts/RyzenShine/configuration.nix,
  # programs.nova), which also installs its udev rules.
  flake.modules.homeManager.desktop-feature-nova = { pkgs, lib, ... }:
    {
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
