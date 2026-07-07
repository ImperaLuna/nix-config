{ ... }:

{
  flake.modules.homeManager.dev-feature-python = { pkgs, ... }: {
    home.packages = [
      pkgs.ruff
      pkgs.ty
      pkgs.uv
    ];
  };
}
