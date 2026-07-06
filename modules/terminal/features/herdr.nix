{ inputs, ... }:

{
  flake.modules.homeManager.terminal-feature-herdr = { pkgs, ... }: {
    home.packages = [
      inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
