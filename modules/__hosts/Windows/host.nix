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
        in
        {
          home.sessionVariables = {
            HM_CONFIG_NAME = "Windows";
            EDITOR = "nvim";
            VISUAL = "nvim";
          };

          home.packages = [
            pkgs.awscli2
            pkgs.docker
          ];

          home.activation.windowsTerminalShiftEnter = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
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

            def is_shift_enter(binding):
                keys = binding.get("keys")
                if isinstance(keys, str):
                    return keys.lower() == "shift+enter"
                if isinstance(keys, list):
                    return any(isinstance(key, str) and key.lower() == "shift+enter" for key in keys)
                return False

            binding = next((item for item in keybindings if is_shift_enter(item)), None)
            if binding is None:
                action_id = "User.sendInput.ShiftEnterNewline"
                keybindings.append({"id": action_id, "keys": "shift+enter"})
            else:
                action_id = binding.get("id") or "User.sendInput.ShiftEnterNewline"
                binding["id"] = action_id
                binding["keys"] = "shift+enter"

            action = next((item for item in actions if item.get("id") == action_id), None)
            command = {"action": "sendInput", "input": "\u001b[13;2u"}
            if action is None:
                actions.append({"command": command, "id": action_id})
            else:
                action["command"] = command

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
