{ inputs, ... }:

{
  flake.modules.homeManager.terminal-feature-claude-code = { pkgs, ... }:
    let
      system = pkgs.stdenv.hostPlatform.system;
      releases = "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases";
      platforms = {
        x86_64-linux = "linux-x64";
        aarch64-linux = "linux-arm64";
        aarch64-darwin = "darwin-arm64";
      };

      # Pinned independently of the llm-agents input. Change it with
      # `claude-pin <version>`, which rewrites version.json and switches.
      pin = builtins.fromJSON (builtins.readFile ./version.json);

      # Reuse the llm-agents build (wrapper, patching, auto-updater off) and
      # swap only the release binary.
      claude-code = inputs.llm-agents.packages.${system}.claude-code.overrideAttrs {
        inherit (pin) version;
        src = pkgs.fetchurl {
          url = "${releases}/${pin.version}/${platforms.${system}}/claude";
          hash = pin.hashes.${system};
        };
      };

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

          versionFile="$flakePath/modules/terminal/features/claude-code/version.json"
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
            }' > "$versionFile"

          echo "claude-pin: pinned claude-code $version"

          if [[ -e /etc/NIXOS ]]; then
            sudo SSH_AUTH_SOCK="''${SSH_AUTH_SOCK:-}" nixos-rebuild switch --flake "$flakePath#$(hostname)"
          else
            home-manager switch --flake "$flakePath#''${HM_CONFIG_NAME:-$(hostname)}"
          fi
        '';
      };

      claudeKeybindings = builtins.toJSON {
        "$schema" = "https://www.schemastore.org/claude-code-keybindings.json";
        "$docs" = "https://code.claude.com/docs/en/keybindings";
        bindings = [
          {
            context = "Chat";
            bindings = {
              "shift+enter" = "chat:newline";
              "ctrl+j" = "chat:newline";
            };
          }
        ];
      };
    in
    {
      home.packages = [
        claude-code
        claude-pin
      ];

      home.file.".claude/keybindings.json".text = claudeKeybindings + "\n";
    };
}
