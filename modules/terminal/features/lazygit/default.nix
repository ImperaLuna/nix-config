{ ... }:

{
  flake.modules.homeManager.terminal-feature-lazygit = { pkgs, ... }: {
    home.packages = [ pkgs.lazygit ];

    xdg.configFile."lazygit/config.yml".source = ./assets/config.yml;
  };
}
