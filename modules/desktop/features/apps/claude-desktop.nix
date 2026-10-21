{ inputs, ... }:

{
  flake.modules.homeManager.apps-feature-claude-desktop = { pkgs, ... }: {
    # Built from Anthropic's official Linux .deb; not in nixpkgs.
    home.packages = [
      inputs.claude-desktop.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
