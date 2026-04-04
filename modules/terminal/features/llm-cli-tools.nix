{ ... }:

{
  flake.modules.homeManager.terminal-feature-llm-cli-tools = { lib, config, pkgs, ... }:
    let
      opencodeCliPlugins = {
        "@opencode-ai/plugin" = "1.3.3";
        opencode-claude-auth = "1.3.3";
      };
      opencodeCliManifest = builtins.toJSON {
        dependencies = opencodeCliPlugins;
      };
    in
    {
      home.packages = [
        pkgs.claude-code
        pkgs.codex
        pkgs.opencode
      ];

      xdg.configFile."opencode/opencode.json" = {
        force = true;
        text = builtins.toJSON {
          "$schema" = "https://opencode.ai/config.json";
          plugin = [ "opencode-claude-auth" ];
        };
      };

      home.activation.ensureOpencodePackageJson = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        opencode_dir="${config.home.homeDirectory}/.config/opencode"
        pkg="$opencode_dir/package.json"

        mkdir -p "$opencode_dir"

        if [ -L "$pkg" ]; then
          rm -f "$pkg"
        fi

        if [ ! -e "$pkg" ]; then
          printf '%s\n' ${lib.escapeShellArg opencodeCliManifest} > "$pkg"
        fi
      '';

    };
}
