{ inputs, ... }:

{
  # A second Claude Code next to the llm-agents `claude`, pinned to the release
  # in version.json and installed as `claude-pinned`. Change the pin with
  # `claude-pin <version>` (or `claude-pin latest` / `claude-pin stable`).
  flake.modules.homeManager.terminal-feature-claude-code = { pkgs, ... }:
    let
      system = pkgs.stdenv.hostPlatform.system;
      releases = "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases";
      platforms = {
        x86_64-linux = "linux-x64";
        aarch64-linux = "linux-arm64";
        aarch64-darwin = "darwin-arm64";
      };

      pin = builtins.fromJSON (builtins.readFile ./version.json);

      # Reuse the llm-agents build (wrapper, patching, auto-updater off) and
      # swap only the release binary.
      pinned = inputs.llm-agents.packages.${system}.claude-code.overrideAttrs {
        inherit (pin) version;
        src = pkgs.fetchurl {
          url = "${releases}/${pin.version}/${platforms.${system}}/claude";
          hash = pin.hashes.${system};
        };
      };

      # Expose only bin/claude-pinned so it does not collide with `claude`.
      claude-pinned = pkgs.runCommand "claude-pinned-${pin.version}" { } ''
        mkdir -p $out/bin
        ln -s ${pinned}/bin/claude $out/bin/claude-pinned
      '';

      claude-pin = pkgs.writeShellApplication {
        name = "claude-pin";
        runtimeInputs = with pkgs; [ curl jq nix ];
        text = ''
          releases="${releases}"
          version="''${1:-latest}"

          if [[ "$version" == "latest" || "$version" == "stable" ]]; then
            version="$(curl -fsSL "$releases/$version")"
          fi

          flakePath=""
          for candidate in "$HOME/nix-config" "$HOME/homelab/nix-config"; do
            if [[ -f "$candidate/flake.nix" ]]; then
              flakePath="$candidate"
              break
            fi
          done
          if [[ -z "$flakePath" ]]; then
            echo "claude-pin: no flake found at ~/nix-config or ~/homelab/nix-config" >&2
            exit 1
          fi

          manifest="$(curl -fsSL "$releases/$version/manifest.json")" || {
            echo "claude-pin: no release manifest for $version" >&2
            exit 1
          }

          sri() {
            nix hash convert --hash-algo sha256 --to sri \
              "$(jq -r --arg p "$1" '.platforms[$p].checksum' <<<"$manifest")"
          }

          jq -n \
            --arg version "$version" \
            --arg darwinArm "$(sri darwin-arm64)" \
            --arg linuxArm "$(sri linux-arm64)" \
            --arg linuxX64 "$(sri linux-x64)" \
            '{
              version: $version,
              hashes: {
                "aarch64-darwin": $darwinArm,
                "aarch64-linux": $linuxArm,
                "x86_64-linux": $linuxX64
              }
            }' > "$flakePath/modules/terminal/features/claude-code/version.json"

          echo "claude-pin: pinned claude-pinned to $version"

          if [[ -e /etc/NIXOS ]]; then
            sudo SSH_AUTH_SOCK="''${SSH_AUTH_SOCK:-}" nixos-rebuild switch --flake "$flakePath#$(hostname)"
          else
            home-manager switch --flake "$flakePath#''${HM_CONFIG_NAME:-$(hostname)}"
          fi
        '';
      };
    in
    {
      home.packages = [
        claude-pinned
        claude-pin
      ];
    };
}
