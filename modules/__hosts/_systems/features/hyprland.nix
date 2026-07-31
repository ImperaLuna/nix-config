{ pkgs, ... }:

{
  # xdg-desktop-portal 1.18+ introduced a caller-verification check that opens
  # /proc/<pid>/root. Sandboxed browser subprocesses (e.g. Firefox/Zen utility
  # processes) set PR_SET_DUMPABLE=0, making their /proc entries root-owned and
  # causing EACCES. The upstream code only handles EACCES for FUSE rootfs; for
  # all other EACCES cases it falls through to G_IO_ERROR_FAILED which the
  # portal surfaces as "Portal operation not allowed", silently killing screen
  # share. The fix: treat non-FUSE EACCES as WRONG_APP_KIND so the caller
  # correctly handles it as "host app, not Flatpak".
  nixpkgs.overlays = [
    (_final: prev: {
      xdg-desktop-portal = prev.xdg-desktop-portal.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          python3 -c "
          content = open('src/xdp-app-info-flatpak.c').read()
          old = (
              '              return -1;\n'
              '            }\n'
              '        }\n'
              '\n'
              '      /* Otherwise, we should be able to open the root dir.'
          )
          new = (
              '              return -1;\n'
              '            }\n'
              '\n'
              '          /* Non-dumpable process (PR_SET_DUMPABLE=0), e.g. a sandboxed\n'
              '           * browser subprocess. /proc/<pid>/root is root-owned. Treat as\n'
              '           * a host app, not a Flatpak. */\n'
              '          g_set_error (error, XDP_APP_INFO_ERROR, XDP_APP_INFO_ERROR_WRONG_APP_KIND,\n'
              '                       \"Not a flatpak (non-dumpable process)\");\n'
              '          return -1;\n'
              '        }\n'
              '\n'
              '      /* Otherwise, we should be able to open the root dir.'
          )
          assert old in content, 'xdp patch: pattern not found in xdp-app-info-flatpak.c'
          open('src/xdp-app-info-flatpak.c', 'w').write(content.replace(old, new, 1))
          print('xdp patch applied successfully')
          "
        '';
      });
    })
  ];

  programs.dconf.enable = true;

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
    ];
    config.hyprland = {
      default = [ "hyprland" "gtk" ];
      ScreenCast = [ "hyprland" ];
      Screenshot = [ "hyprland" ];
    };
  };

  environment.systemPackages = with pkgs; [
    wl-clipboard
    grim
    slurp
    libnotify
    playerctl
    brightnessctl
    adwaita-icon-theme
  ];
}
