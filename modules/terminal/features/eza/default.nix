{ ... }:

{
  flake.modules.homeManager.terminal-feature-eza = { pkgs, ... }: {
    home.packages = [ pkgs.eza ];

    xdg.configFile."eza/theme.yml".source = ./assets/theme.yml;
  };
}
