{ ... }:

{
  flake.modules.homeManager.terminal-feature-llm-cli-tools = { lib, pkgs, ... }:
    let
      codexInsertNewline = ''insert_newline = ["ctrl-enter", "shift-enter"]'';

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

      omp = pkgs.stdenvNoCC.mkDerivation rec {
        pname = "omp";
        version = "16.4.0";

        src = pkgs.fetchurl {
          url = "https://github.com/can1357/oh-my-pi/releases/download/v${version}/omp-linux-x64";
          hash = "sha256-x6L6MoyWUTHA0O9ioHpP5jMG7Rt6kPu7kkx1YFxo04o=";
        };

        dontUnpack = true;
        nativeBuildInputs = [ pkgs.makeWrapper ];

        installPhase = ''
          runHook preInstall

          install -Dm755 $src $out/libexec/omp
          makeWrapper ${pkgs.stdenv.cc.bintools.dynamicLinker} $out/bin/omp \
            --add-flags $out/libexec/omp

          runHook postInstall
        '';
      };
    in
    {
      home.packages = [
        pkgs.claude-code
        pkgs.codex
        pkgs.opencode
        pkgs.pi-coding-agent
        omp
      ];

      home.file.".claude/keybindings.json".text = claudeKeybindings + "\n";

      home.file.".omp/agent/keybindings.yml".text = ''
        tui.input.newLine:
          - Shift+Enter
          - Ctrl+J
      '';

      # Codex keeps trusted projects, hook hashes, and first-run state in the same
      # TOML file, so patch only the keymap entry instead of replacing the file.
      home.activation.codexNewlineKeymap = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        config_file="$HOME/.codex/config.toml"
        desired='${codexInsertNewline}'

        mkdir -p "$HOME/.codex"

        if [ ! -f "$config_file" ]; then
          cat > "$config_file" <<EOF
        [tui.keymap.editor]
        $desired
        EOF
          exit 0
        fi

        tmp_file="$(mktemp)"

        ${pkgs.gawk}/bin/awk -v desired="$desired" '
          function is_header(line) {
            return line ~ /^[[:space:]]*\[/
          }

          /^[[:space:]]*\[tui\.keymap\.editor\][[:space:]]*$/ {
            in_table = 1
            seen_table = 1
            print
            next
          }

          in_table && is_header($0) {
            if (!wrote) {
              print desired
              wrote = 1
            }
            in_table = 0
          }

          in_table && /^[[:space:]]*insert_newline[[:space:]]*=/ {
            if (!wrote) {
              print desired
              wrote = 1
            }
            next
          }

          {
            print
          }

          END {
            if (!seen_table) {
              print ""
              print "[tui.keymap.editor]"
              print desired
            } else if (in_table && !wrote) {
              print desired
            }
          }
        ' "$config_file" > "$tmp_file"

        if cmp -s "$tmp_file" "$config_file"; then
          rm "$tmp_file"
        else
          mv "$tmp_file" "$config_file"
        fi
      '';
    };
}
