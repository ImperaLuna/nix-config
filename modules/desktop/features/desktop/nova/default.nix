{ inputs, lib, ... }:

{
  flake.modules.homeManager.desktop-feature-nova = { pkgs, ... }:
    let
      nova = inputs.nova.packages.${pkgs.stdenv.hostPlatform.system}.withCalculator;

      iconThemePackages = [
        pkgs.adwaita-icon-theme
        pkgs.hicolor-icon-theme
        pkgs.kdePackages.breeze-icons
        pkgs.nixos-icons
      ];

      iconThemeDataDirs = lib.makeSearchPath "share" iconThemePackages;

      novaWithIconSearchPath = pkgs.writeShellApplication {
        name = "nova";
        runtimeInputs = [ nova ];
        text = ''
          prepend_xdg_data_dir() {
            if [ -d "$1" ]; then
              case ":''${XDG_DATA_DIRS:-}:" in
                *:"$1":*) ;;
                *) export XDG_DATA_DIRS="$1''${XDG_DATA_DIRS:+:''${XDG_DATA_DIRS}}" ;;
              esac
            fi
          }

          prepend_xdg_data_dirs() {
            local old_ifs="$IFS"
            IFS=:
            for dir in $1; do
              prepend_xdg_data_dir "$dir"
            done
            IFS="$old_ifs"
          }

          prepend_xdg_data_dir "''${XDG_DATA_HOME:-$HOME/.local/share}"
          prepend_xdg_data_dir "$HOME/.nix-profile/share"
          prepend_xdg_data_dir "/etc/profiles/per-user/''${USER:-imperaluna}/share"
          prepend_xdg_data_dir "/run/current-system/sw/share"
          prepend_xdg_data_dirs "${iconThemeDataDirs}"

          exec ${nova}/bin/nova "$@"
        '';
      };
    in
    {
      home.packages = [
        novaWithIconSearchPath
      ];

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
