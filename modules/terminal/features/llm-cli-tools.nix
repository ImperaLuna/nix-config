{ inputs, ... }:

{
  flake.modules.homeManager.terminal-feature-llm-cli-tools = { lib, pkgs, ... }:
    let
      agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};

      # The upstream OMP binary has Nix's dynamic loader but no glibc runtime
      # search path.  On non-NixOS systems (notably WSL) it mixes Nix's loader
      # with the host libc and segfaults before startup.  Patch a copy of the
      # cached binary so OMP keeps the adjacent native addon it expects without
      # rebuilding the large Bun application.
      omp = pkgs.runCommand "omp-${agents.omp.version}" {
        nativeBuildInputs = [
          pkgs.makeWrapper
          pkgs.patchelf
        ];
        meta = agents.omp.meta;
      } ''
        mkdir -p "$out/bin" "$out/lib"
        cp -r ${agents.omp}/lib/omp "$out/lib/omp"
        chmod -R u+w "$out/lib/omp"

        patchelf --set-rpath "${lib.makeLibraryPath [
          pkgs.glibc
          pkgs.stdenv.cc.cc.lib
          pkgs.zlib
        ]}" "$out/lib/omp/omp"

        makeWrapper "$out/lib/omp/omp" "$out/bin/omp" \
          --set PI_SKIP_VERSION_CHECK 1
      '';

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

    in
    {
      home.packages = [
        agents.claude-code
        agents.codex
        omp
        agents.pi
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
