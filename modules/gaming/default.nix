{ config, ... }:

{
  imports = import ../_lib/import-feature-tree.nix ./features;

  flake.modules.homeManager.gaming = { pkgs, ... }:
    let
      steamLauncher = pkgs.writeShellScript "steam-launch" ''
        if [ "$#" -gt 0 ]; then
          exec /run/current-system/sw/bin/steam "$@"
        fi

        exec /run/current-system/sw/bin/steam steam://open/main
      '';
    in
    {
      imports = [
        config.flake.modules.homeManager.gaming-feature-albion
        config.flake.modules.homeManager.gaming-feature-albion-autorun
      ];

      # Use the system Steam launcher directly so application launchers do not
      # depend on shell PATH or UWSM desktop-entry handling.
      xdg.desktopEntries.steam = {
        name = "Steam";
        exec = "${steamLauncher} %U";
        icon = "steam";
        comment = "Application for managing and playing games on Steam";
        categories = [ "Game" ];
      };

      # Quickshell-based launchers can encounter both this managed entry and
      # the system Steam entry. Put our absolute-path launcher in XDG_DATA_HOME
      # as well so it wins regardless of XDG_DATA_DIRS merge order.
      home.file.".local/share/applications/steam.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Version=1.5
        Name=Steam
        Comment=Application for managing and playing games on Steam
        Exec=${steamLauncher} %U
        Icon=steam
        Terminal=false
        Categories=Game;
        MimeType=x-scheme-handler/steam;x-scheme-handler/steamlink;
      '';
    };
}
