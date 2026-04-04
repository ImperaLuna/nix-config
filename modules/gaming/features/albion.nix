{ ... }:

{
  flake.modules.homeManager.gaming-feature-albion = { config, lib, pkgs, ... }:
    let
      albionLauncher = pkgs.writeShellScript "albion-launch" ''
        if /run/current-system/sw/bin/steam steam://rungameid/17150733693560553472 >/dev/null 2>&1; then
          exit 0
        fi
        exec "${config.home.homeDirectory}/albiononline/Albion-Online"
      '';
    in
    {
    home.file.".local/share/applications/sandbox-interactive_com-albiononline_1.desktop" = {
      force = true;
      text = ''
        [Desktop Entry]
        Type=Application
        Name=Albion Online
        GenericName=Albion Online
        Comment=Play Albion Online!
        Icon=${config.home.homeDirectory}/albiononline/AlbionOnline.xpm
        Exec=${albionLauncher}
        Path=${config.home.homeDirectory}/albiononline
        Terminal=false
        StartupNotify=false
        StartupWMClass=Albion-Online
        Categories=Game;
      '';
    };

    home.activation.removeLegacyAlbionDesktop = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
      legacy_desktop="${config.home.homeDirectory}/.local/share/applications/sandbox-interactive_com-albiononline_1.desktop"
      if [ -e "$legacy_desktop" ] && [ ! -L "$legacy_desktop" ]; then
        rm -f "$legacy_desktop"
      fi
    '';
    };
}
