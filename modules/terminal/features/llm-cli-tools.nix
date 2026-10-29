{ inputs, ... }:

{
  flake.modules.homeManager.terminal-feature-llm-cli-tools = { config, lib, pkgs, ... }:
    let
      cfg = config.modules.llm-cli-tools;
      agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};

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
      options.modules.llm-cli-tools.nativeVoice = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Use Claude Code's native ALSA voice capture. Turn off where audio only reaches PulseAudio (WSLg), so /voice falls back to SoX.";
      };

      options.modules.llm-cli-tools.claudeAllow = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [ "Bash(systemctl start nixos-apply)" ];
        description = "Claude Code permission rules added to permissions.allow in ~/.claude/settings.json, so sessions run these without asking.";
      };

      config = {
        home.packages =
          if cfg.nativeVoice then
            [
              # Claude Code's /voice uses a bundled native capture module that
              # links libasound.so.2, so put alsa-lib on the loader path.
              (pkgs.symlinkJoin {
                name = "claude-code-alsa";
                paths = [ agents.claude-code ];
                nativeBuildInputs = [ pkgs.makeWrapper ];
                postBuild = ''
                  wrapProgram $out/bin/claude \
                    --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ pkgs.alsa-lib ]}
                '';
              })
              agents.codex
            ]
          else
            [
              # Without the native module, /voice records through SoX's `rec`.
              agents.claude-code
              pkgs.sox
              agents.codex
            ];

        home.file.".claude/keybindings.json".text = claudeKeybindings + "\n";

        # Claude Code writes its own settings.json (model, plugins, /config), so
        # merge only the allow rules from this module. The rules written last
        # time are kept in a state file, so a rule removed here is removed there.
        home.activation.claudeAllowRules = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          settings="$HOME/.claude/settings.json"
          state="''${XDG_STATE_HOME:-$HOME/.local/state}/claude-allow-rules.json"
          desired='${builtins.toJSON cfg.claudeAllow}'

          # Hosts that never set any rules leave settings.json alone.
          if [ "$desired" != "[]" ] || [ -s "$state" ]; then
            mkdir -p "$HOME/.claude" "$(dirname "$state")"
            [ -s "$settings" ] || echo '{}' > "$settings"
            [ -s "$state" ] || echo '[]' > "$state"

            tmp_file="$(mktemp)"
            ${pkgs.jq}/bin/jq --argjson desired "$desired" --slurpfile previous "$state" '
              .permissions.allow = ((.permissions.allow // []) - $previous[0] - $desired) + $desired
            ' "$settings" > "$tmp_file"

            if cmp -s "$tmp_file" "$settings"; then
              rm "$tmp_file"
            else
              mv "$tmp_file" "$settings"
            fi
            echo "$desired" > "$state"
          fi
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
    };
}
