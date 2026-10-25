{ inputs, lib, ... }:

{
  flake.modules.homeManager.desktop-feature-nova = { pkgs, ... }:
    let
      novaRebuild = inputs.nova-rebuild.packages.${pkgs.stdenv.hostPlatform.system}.nova;
      novaUnit = "${novaRebuild}/lib/systemd/user/nova.service";

      iconThemePackages = [
        pkgs.adwaita-icon-theme
        pkgs.hicolor-icon-theme
        pkgs.kdePackages.breeze-icons
        pkgs.nixos-icons
      ];
    in
    {
      # The icon themes are on the profile so the launcher finds app icons.
      home.packages = [ novaRebuild ] ++ iconThemePackages;

      # The package's own unit, started with the session (niri). Hyprland
      # starts it through `exec-once = nova`.
      xdg.configFile."systemd/user/nova.service".source = novaUnit;
      xdg.configFile."systemd/user/graphical-session.target.wants/nova.service".source = novaUnit;

      # Bridge legacy XEmbed tray icons from Wine apps into Nova's SNI tray.
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
