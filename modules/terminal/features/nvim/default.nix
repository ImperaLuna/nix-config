{ inputs, ... }:

{
  flake.modules.homeManager.terminal-feature-nvim = { config, ... }: {
    imports = [
      inputs.nixvim.homeModules.nixvim
      ./_config.nix
    ];

    home.packages = [
      config.programs.nixvim.build.package
    ];

    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

}
