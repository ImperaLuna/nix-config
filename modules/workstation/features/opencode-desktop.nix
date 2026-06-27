{ ... }:

{
  flake.modules.homeManager.workstation-feature-opencode-desktop = { lib, pkgs, ... }:
    let
      zedCliCompat = pkgs.writeShellScriptBin "zed" ''
        exec ${pkgs.zed-editor}/bin/zeditor "$@"
      '';

      opencodeDesktopFixed = pkgs.symlinkJoin {
        name = "opencode-desktop-fixed";
        paths = [ pkgs.opencode-desktop ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram "$out/bin/opencode-desktop" \
            --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "${pkgs.gst_all_1.gst-plugins-base}/lib/gstreamer-1.0:${pkgs.gst_all_1.gst-plugins-good}/lib/gstreamer-1.0" \
            --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ pkgs.stdenv.cc.cc.lib ]}" \
            --prefix PATH : "${lib.makeBinPath [ pkgs.zed-editor zedCliCompat ]}"
        '';
      };
    in
    {
      home.packages = [ opencodeDesktopFixed ];

      xdg.configFile."opencode/opencode.json".text = builtins.toJSON {
        "$schema" = "https://opencode.ai/config.json";
        permission = {
          edit = "allow";
          bash = {
            "*" = "allow";
            "rm *" = "ask";
            "sudo *" = "ask";
          };
          external_directory = "allow";
        };
      };

      xdg.configFile."opencode/tui.json".text = builtins.toJSON {
        "$schema" = "https://opencode.ai/tui.json";
        keybinds.input_submit = "return,kpenter";
      };
    };
}
