{ ... }:

{
  flake.modules.homeManager.terminal-feature-proton-pass-cli = { pkgs, ... }: {
    home.packages = [ pkgs.proton-pass-cli ];
  };
}
