{ mkHome, ... }:

{
  Windows = mkHome {
    username = "rbrezeanu";
    homeDirectory = "/home/rbrezeanu";
    userConfig = ../../../modules/credentials/rbrezeanu;
    extraModules = [
      ({ lib, pkgs, ... }:
        let
          windowsTerminalSettings =
            "/mnt/c/Users/rbrezeanu/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json";
          # WSL binfmt_misc can be unavailable under systemd, which makes direct
          # Windows .exe launches look like shell scripts. OMP uses powershell.exe
          # for Windows clipboard reads, so route it through WSL's /init interop.
          windowsPowershell = pkgs.writeShellScriptBin "powershell.exe" ''
            exec /init /mnt/c/WINDOWS/System32/WindowsPowerShell/v1.0/powershell.exe "$@"
          '';
          windowsClipboardCopy = pkgs.writeShellScriptBin "nvim-windows-clipboard-copy" ''
            exec /init /mnt/c/WINDOWS/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -NonInteractive -Command '[Console]::InputEncoding = [Text.Encoding]::UTF8; Set-Clipboard -Value ([Console]::In.ReadToEnd())'
          '';
          windowsClipboardPaste = pkgs.writeShellScriptBin "nvim-windows-clipboard-paste" ''
            exec /init /mnt/c/WINDOWS/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -NonInteractive -Command '[Console]::OutputEncoding = [Text.Encoding]::UTF8; [Console]::Out.Write([string](Get-Clipboard -Raw))'
          '';
        in
        {
          home.sessionVariables = {
            HM_CONFIG_NAME = "Windows";
            EDITOR = "nvim";
            VISUAL = "nvim";
          };

          programs.nixvim.extraConfigLuaPre = ''
            vim.g.clipboard = {
              name = "WindowsClipboard",
              copy = {
                ["+"] = "nvim-windows-clipboard-copy",
                ["*"] = "nvim-windows-clipboard-copy",
              },
              paste = {
                ["+"] = "nvim-windows-clipboard-paste",
                ["*"] = "nvim-windows-clipboard-paste",
              },
              cache_enabled = 0,
            }
          '';

          home.packages = [
            pkgs.awscli2
            windowsPowershell
            windowsClipboardCopy
            windowsClipboardPaste
            pkgs.docker
          ];

          # WSL Home Manager cannot express these as normal dotfiles because the
          # terminal emulator lives on the Windows side. Patch Windows Terminal's
          # settings.json so Shift+Enter sends CSI-u Shift+Enter (13;2u), and
          # Ctrl+Alt+V sends Ctrl+V through to Codex for image clipboard paste.
          home.activation.windowsTerminalKeybindings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            settings_file="${windowsTerminalSettings}"

            if [ -f "$settings_file" ]; then
              ${pkgs.python3}/bin/python3 - "$settings_file" <<'PY'
            import json
            import sys
            from pathlib import Path

            path = Path(sys.argv[1])
            data = json.loads(path.read_text())

            actions = data.setdefault("actions", [])
            keybindings = data.setdefault("keybindings", [])

            def has_keys(binding, desired):
                keys = binding.get("keys")
                if isinstance(keys, str):
                    return keys.lower() == desired
                if isinstance(keys, list):
                    return any(isinstance(key, str) and key.lower() == desired for key in keys)
                return False

            def ensure_send_input(keys, default_action_id, input_text):
                binding = next((item for item in keybindings if has_keys(item, keys)), None)
                if binding is None:
                    action_id = default_action_id
                    keybindings.append({"id": action_id, "keys": keys})
                else:
                    action_id = binding.get("id") or default_action_id
                    binding["id"] = action_id
                    binding["keys"] = keys

                action = next((item for item in actions if item.get("id") == action_id), None)
                command = {"action": "sendInput", "input": input_text}
                if action is None:
                    actions.append({"command": command, "id": action_id})
                else:
                    action["command"] = command

            ensure_send_input("shift+enter", "User.sendInput.ShiftEnterNewline", "\u001b[13;2u")
            ensure_send_input("ctrl+alt+v", "User.sendInput.CodexPasteImage", "\u0016")

            rendered = json.dumps(data, indent=4) + "\n"
            if path.read_text() != rendered:
                path.write_text(rendered)
            PY
            fi
          '';

          programs.fish.shellInit = lib.mkAfter ''
            # WSL imports Windows PATH entries verbatim. Some installers add an
            # executable instead of its parent directory, which makes fish command
            # lookup fail with "component ... is not a directory".
            set -l clean_path
            for path_entry in "$HOME/.local/bin" "$HOME/.nix-profile/bin" /nix/var/nix/profiles/default/bin $PATH
              contains -- "$path_entry" $clean_path
              and continue

              if test ! -e "$path_entry"; or test -d "$path_entry"
                set -a clean_path "$path_entry"
              end
            end
            set -gx PATH $clean_path

            set -gx HM_CONFIG_NAME Windows
            set -gx EDITOR nvim
            set -gx VISUAL nvim
          '';
        })
    ];
  };
}
