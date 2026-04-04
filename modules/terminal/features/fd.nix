{ ... }:

{
  flake.modules.homeManager.terminal-feature-fd = { pkgs, ... }: {
    home.packages = [ pkgs.fd ];
  };
}
