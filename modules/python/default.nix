{ ... }:

{
  flake.modules.homeManager.python = { pkgs, ... }: {
    home.packages = with pkgs; [
      python3
      uv
      ty
      ruff
    ];
  };
}
