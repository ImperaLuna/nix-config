{ ... }:

{
  flake.modules.homeManager.terminal-feature-btop = { pkgs, config, ... }: {
    home.packages = [ pkgs.btop ];

    xdg.configFile."btop/btop.conf".text =
      builtins.replaceStrings
        [ "/home/imperaluna" ]
        [ config.home.homeDirectory ]
        (builtins.readFile ./assets/btop.conf);

    xdg.configFile."btop/themes/catppuccin_mocha.theme".source =
      ./assets/themes/catppuccin_mocha.theme;
  };
}
