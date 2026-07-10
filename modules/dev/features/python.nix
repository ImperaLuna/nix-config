{ ... }:

{
  flake.modules.homeManager.dev-feature-python = { pkgs, ... }: {
    home.packages = [
      pkgs.python3
      pkgs.ruff
      pkgs.ty
      pkgs.uv
    ];
  };
}
