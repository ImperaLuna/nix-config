{ inputs, ... }:

{
  flake.modules.homeManager.desktop-feature-nova = { pkgs, ... }: {
    home.packages = [
      inputs.nova.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
