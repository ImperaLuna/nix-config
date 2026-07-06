{ ... }:

{
  programs.fish = {
    shellAliases = {
      cat = "bat";
      ls = "eza --icons --color=always";
    };

    shellAbbrs = {
      devup = "kubectl scale deployment -n homelab-dev --replicas=1 --all";
      devdown = "kubectl scale deployment -n homelab-dev --replicas=0 --all";
      batn = "cat --style=full --paging=auto";
      gs = "git status";
      install = "nix shell nixpkgs#";
      search = "nix search nixpkgs";
    };

    functions.rebuild = ''
      set -l flakePath

      for candidate in ~/nix-config ~/homelab/nix-config
        if test -f "$candidate/flake.nix"
          set flakePath "$candidate"
          break
        end
      end

      if test -z "$flakePath"
        echo "rebuild: no flake found at ~/nix-config or ~/homelab/nix-config" >&2
        return 1
      end

      sudo SSH_AUTH_SOCK="$SSH_AUTH_SOCK" nixos-rebuild switch --flake "$flakePath#"(hostname) $argv
    '';

    functions.upgrade = ''
      set -l flakePath

      for candidate in ~/nix-config ~/homelab/nix-config
        if test -f "$candidate/flake.nix"
          set flakePath "$candidate"
          break
        end
      end

      if test -z "$flakePath"
        echo "upgrade: no flake found at ~/nix-config or ~/homelab/nix-config" >&2
        return 1
      end

      nix flake update --flake "$flakePath" $argv
      or return $status

      sudo SSH_AUTH_SOCK="$SSH_AUTH_SOCK" nixos-rebuild switch --flake "$flakePath#"(hostname)
    '';

    functions.homeswitch = ''
      set -l flakePath
      set -l hostName (hostname)
      set -l configName

      for candidate in ~/nix-config ~/homelab/nix-config
        if test -f "$candidate/flake.nix"
          set flakePath "$candidate"
          break
        end
      end

      if test -z "$flakePath"
        echo "homeswitch: no flake found at ~/nix-config or ~/homelab/nix-config" >&2
        return 1
      end

      if set -q HM_CONFIG_NAME
        set configName "$HM_CONFIG_NAME"
      else
        set configName "$hostName"
      end

      set -l hmAttr
      if nix eval "path:$flakePath#homeConfigurations.\"$configName\".activationPackage.drvPath" >/dev/null 2>&1
        set hmAttr "homeConfigurations.\"$configName\".activationPackage"
      else
        set hmAttr "nixosConfigurations.\"$hostName\".config.home-manager.users.$USER.home.activationPackage"
      end

      set -l activationPkg (nix build "path:$flakePath#$hmAttr" --no-link --print-out-paths $argv)

      if test -z "$activationPkg"
        echo "homeswitch: failed to build activation package for $USER using $hmAttr" >&2
        return 1
      end

      if pgrep -x zen >/dev/null; or pgrep -x zen-beta >/dev/null
        echo "homeswitch: Zen is running; close it first so declarative spaces/pins can be applied." >&2
        return 1
      end

      env HOME_MANAGER_BACKUP_EXT=hm-backup HOME_MANAGER_BACKUP_OVERWRITE=1 "$activationPkg"/activate
    '';
  };
}
