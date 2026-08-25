{ ... }:

{
  flake.modules.homeManager.dev-feature-python = { pkgs, ... }: {
    home.packages = [
      pkgs.python3
      pkgs.poethepoet   # global `poe`; runs tasks in each project venv via uv.lock
      pkgs.ruff
      pkgs.ty
      pkgs.uv
    ];
  };
}
