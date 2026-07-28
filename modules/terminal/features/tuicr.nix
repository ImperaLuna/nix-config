{ ... }:

{
  flake.modules.homeManager.terminal-feature-tuicr = { pkgs, ... }: {
    home.packages = [ pkgs.tuicr ];
  };
}
