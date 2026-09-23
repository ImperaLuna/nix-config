{
  flake.modules.homeManager.terminal-feature-herdr = { pkgs, ... }: {
    home.packages = [ pkgs.herdr ];
  };
}
