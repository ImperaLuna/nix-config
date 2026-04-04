{ lib, config, pkgs, ... }:

let
  cfg = config.modules.llm_cli_tools;
  opencodeCliPlugins = {
    "@opencode-ai/plugin" = "1.3.3";
    "opencode-claude-auth" = "1.3.3";
  };
  opencodeCliManifest = builtins.toJSON {
    dependencies = opencodeCliPlugins;
  };
  opencodeDesktopPlugins = {
    "@opencode-ai/plugin" = "1.3.3";
  };
  opencodeDesktopManifest = builtins.toJSON {
    dependencies = opencodeDesktopPlugins;
  };
  opencodeDesktopFixed = pkgs.symlinkJoin {
    name = "opencode-desktop-fixed";
    paths = [ pkgs.opencode-desktop ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram "$out/bin/OpenCode" \
        --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "${pkgs.gst_all_1.gst-plugins-base}/lib/gstreamer-1.0:${pkgs.gst_all_1.gst-plugins-good}/lib/gstreamer-1.0" \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ pkgs.stdenv.cc.cc.lib ]}" \
        --set XDG_CONFIG_HOME "${config.home.homeDirectory}/.config/opencode-desktop"
    '';
  };
in

{
  options.modules.llm_cli_tools = {
    claude-code = lib.mkEnableOption "claude-code";
    codex       = lib.mkEnableOption "codex";
    opencode    = lib.mkEnableOption "opencode";
    opencode-desktop = lib.mkEnableOption "opencode-desktop";
  };

  config = {
    home.packages =
      lib.optional cfg.claude-code pkgs.claude-code
      ++ lib.optional cfg.codex    pkgs.codex
      ++ lib.optional cfg.opencode pkgs.opencode
      ++ lib.optional cfg.opencode-desktop opencodeDesktopFixed;

    xdg.configFile."opencode/opencode.json" = lib.mkIf cfg.opencode {
      force = true;
      text = builtins.toJSON {
        "$schema" = "https://opencode.ai/config.json";
        plugin = [ "opencode-claude-auth" ];
      };
    };

    xdg.configFile."opencode-desktop/opencode/opencode.json" = lib.mkIf cfg.opencode-desktop {
      force = true;
      text = builtins.toJSON {
        "$schema" = "https://opencode.ai/config.json";
        plugin = [ ];
      };
    };

    home.activation.ensureOpencodePackageJson = lib.mkIf cfg.opencode (lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      opencode_dir="${config.home.homeDirectory}/.config/opencode"
      pkg="$opencode_dir/package.json"

      mkdir -p "$opencode_dir"

      if [ -L "$pkg" ]; then
        rm -f "$pkg"
      fi

      if [ ! -e "$pkg" ]; then
        printf '%s\n' ${lib.escapeShellArg opencodeCliManifest} > "$pkg"
      fi
    '');

    home.activation.ensureOpencodeDesktopPackageJson = lib.mkIf cfg.opencode-desktop (lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      opencode_dir="${config.home.homeDirectory}/.config/opencode-desktop/opencode"
      pkg="$opencode_dir/package.json"

      mkdir -p "$opencode_dir"

      if [ -L "$pkg" ]; then
        rm -f "$pkg"
      fi

      if [ ! -e "$pkg" ]; then
        printf '%s\n' ${lib.escapeShellArg opencodeDesktopManifest} > "$pkg"
      fi
    '');
  };
}
