{ ... }:

{
  flake.modules.homeManager.terminal-feature-btop = { pkgs, config, ... }:
    let
      btopLauncher = pkgs.writeShellScriptBin "btop-launch" ''
        exec ${pkgs.ghostty}/bin/ghostty -e ${pkgs.btop}/bin/btop "$@"
      '';
    in
    {
      home.packages = [ pkgs.btop btopLauncher ];

      xdg.configFile."btop/btop.conf".text =
        builtins.replaceStrings
          [ "/home/imperaluna" ]
          [ config.home.homeDirectory ]
          (builtins.readFile ./assets/btop.conf);

      xdg.configFile."btop/themes/catppuccin_mocha.theme".source =
        ./assets/themes/catppuccin_mocha.theme;

      xdg.desktopEntries.btop = {
        name = "Btop";
        genericName = "System Monitor";
        exec = "btop-launch";
        icon = "btop";
        categories = [ "System" "Monitor" ];
        startupNotify = true;
      };
    };
}
