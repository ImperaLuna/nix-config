{ lib, config, inputs, pkgs, ... }:

let
  llm = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  opencodeCliPlugins = {
    "@opencode-ai/plugin" = "1.3.3";
    opencode-claude-auth = "1.3.3";
  };
  opencodeDesktopPlugins = {
    "@opencode-ai/plugin" = "1.3.3";
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
  home.packages = [
    llm.claude-code
    llm.codex
    llm.opencode
    opencodeDesktopFixed
  ];

  xdg.configFile."opencode/package.json" = {
    force = true;
    text = builtins.toJSON {
      dependencies = opencodeCliPlugins;
    };
  };

  xdg.configFile."opencode/opencode.json" = {
    force = true;
    text = builtins.toJSON {
      "$schema" = "https://opencode.ai/config.json";
      plugin = [ "opencode-claude-auth" ];
    };
  };

  xdg.configFile."opencode-desktop/opencode/package.json" = {
    force = true;
    text = builtins.toJSON {
      dependencies = opencodeDesktopPlugins;
    };
  };

  xdg.configFile."opencode-desktop/opencode/opencode.json" = {
    force = true;
    text = builtins.toJSON {
      "$schema" = "https://opencode.ai/config.json";
      plugin = [ ];
    };
  };
}
