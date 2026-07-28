{ ... }:

{
  flake.modules.homeManager.terminal-feature-zsh = {
    programs.zsh = {
      enable = true;
      shellAliases = {
        cat = "command bat --style=plain --paging=never";
        ls = "eza --icons=always --color=always";
        install = "nix shell nixpkgs#";
        search = "nix search nixpkgs";
      };
      initExtra = ''
        function rebuild() {
          local flakePath

          for candidate in ~/nix-config ~/homelab/nix-config; do
            if [[ -f "$candidate/flake.nix" ]]; then
              flakePath="$candidate"
              break
            fi
          done

          if [[ -z "$flakePath" ]]; then
            print -u2 "rebuild: no flake found at ~/nix-config or ~/homelab/nix-config"
            return 1
          fi

          sudo SSH_AUTH_SOCK="''${SSH_AUTH_SOCK:-}" nixos-rebuild switch --flake "$flakePath#$(hostname)" "$@"
        }

        function upgrade() {
          local flakePath

          for candidate in ~/nix-config ~/homelab/nix-config; do
            if [[ -f "$candidate/flake.nix" ]]; then
              flakePath="$candidate"
              break
            fi
          done

          if [[ -z "$flakePath" ]]; then
            print -u2 "upgrade: no flake found at ~/nix-config or ~/homelab/nix-config"
            return 1
          fi

          nix flake update --flake "$flakePath" "$@" || return $?

          sudo SSH_AUTH_SOCK="''${SSH_AUTH_SOCK:-}" nixos-rebuild switch --flake "$flakePath#$(hostname)"
        }

        function homeswitch() {
          local flakePath
          local hostName="$(hostname)"
          local configName
          local hmAttr
          local activationPkg

          for candidate in ~/nix-config ~/homelab/nix-config; do
            if [[ -f "$candidate/flake.nix" ]]; then
              flakePath="$candidate"
              break
            fi
          done

          if [[ -z "$flakePath" ]]; then
            print -u2 "homeswitch: no flake found at ~/nix-config or ~/homelab/nix-config"
            return 1
          fi

          if [[ -n "''${HM_CONFIG_NAME:-}" ]]; then
            configName="$HM_CONFIG_NAME"
          else
            configName="$hostName"
          fi

          if nix eval "path:$flakePath#homeConfigurations.\"$configName\".activationPackage.drvPath" >/dev/null 2>&1; then
            hmAttr="homeConfigurations.\"$configName\".activationPackage"
          else
            hmAttr="nixosConfigurations.\"$hostName\".config.home-manager.users.$USER.home.activationPackage"
          fi

          activationPkg="$(nix build "path:$flakePath#$hmAttr" --no-link --print-out-paths "$@")"
          if [[ -z "$activationPkg" ]]; then
            print -u2 "homeswitch: failed to build activation package for $USER using $hmAttr"
            return 1
          fi

          if pgrep -x zen >/dev/null || pgrep -x zen-beta >/dev/null; then
            print -u2 "homeswitch: Zen is running; close it first so declarative spaces/pins can be applied."
            return 1
          fi

          env HOME_MANAGER_BACKUP_EXT=hm-backup HOME_MANAGER_BACKUP_OVERWRITE=1 "$activationPkg/activate"
        }
      '';
    };
  };
}
