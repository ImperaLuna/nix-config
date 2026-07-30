{ ... }:

{
  flake.modules.homeManager.dev-feature-opencode = { pkgs, ... }: {
    home.packages = [
      pkgs.opencode
    ];
  };
}
