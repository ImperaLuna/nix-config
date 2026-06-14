{ ... }:

{
  flake.modules.homeManager.terminal-feature-btop = { pkgs, config, ... }:
    let
      btopGhostty = pkgs.writeShellScriptBin "btop-ghostty" ''
        exec ${pkgs.ghostty}/bin/ghostty \
          --config-file="${config.xdg.configHome}/ghostty/btop.conf" \
          --config-default-files=false \
          -e ${pkgs.btop}/bin/btop "$@"
      '';

      ghosttyBtopConfig =
        builtins.replaceStrings
          [
            ''
              # Shaders
              custom-shader = ~/.config/ghostty/shaders/cursor_blaze.glsl
              custom-shader = ~/.config/ghostty/shaders/sparks-from-fire.glsl
              custom-shader-animation = always
            ''
          ]
          [ "" ]
          (builtins.readFile ../../../desktop/features/ghostty/assets/config);
    in
    {
      home.packages = [
        pkgs.btop
        btopGhostty
      ];

      xdg.configFile."btop/btop.conf".text =
        builtins.replaceStrings
          [ "/home/imperaluna" ]
          [ config.home.homeDirectory ]
          (builtins.readFile ./assets/btop.conf);

      xdg.configFile."btop/themes/catppuccin_mocha.theme".source =
        ./assets/themes/catppuccin_mocha.theme;

      xdg.configFile."ghostty/btop.conf".text = ghosttyBtopConfig;

      xdg.desktopEntries.btop = {
        name = "Btop";
        genericName = "System Monitor";
        exec = "btop-ghostty";
        icon = "btop";
        categories = [ "System" "Monitor" ];
        startupNotify = true;
      };

      home.file.".local/share/applications/btop.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=Btop
        GenericName=System Monitor
        Exec=btop-ghostty
        Icon=btop
        Categories=System;Monitor;
        StartupNotify=true
      '';
    };
}
