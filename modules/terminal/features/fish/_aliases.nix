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

      sudo nixos-rebuild switch --flake "$flakePath#"(hostname) $argv
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

      sudo nixos-rebuild switch --flake "$flakePath#"(hostname)
    '';

    functions.homeswitch = ''
      set -l flakePath
      set -l hostName (hostname)

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

      set -l hmAttr "nixosConfigurations.\"$hostName\".config.home-manager.users.$USER.home.activationPackage"
      set -l activationPkg (nix build "$flakePath#$hmAttr" --no-link --print-out-paths $argv)

      if test -z "$activationPkg"
        echo "homeswitch: failed to build activation package for $USER@$hostName" >&2
        return 1
      end

      "$activationPkg"/activate
    '';
  };
}
