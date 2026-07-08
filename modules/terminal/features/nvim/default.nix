{ inputs, ... }:

{
  flake.modules.homeManager.terminal-feature-nvim = { config, pkgs, ... }:
    let
      nvimLauncher = pkgs.writeShellScriptBin "nvim-launch" ''
        exec ${pkgs.ghostty}/bin/ghostty -e ${config.programs.nixvim.build.package}/bin/nvim "$@"
      '';
    in
    {
      imports = [
        inputs.nixvim.homeModules.nixvim
        ./_config.nix
      ];

      home.packages = [
        config.programs.nixvim.build.package
        pkgs.wl-clipboard
        nvimLauncher
      ];

      home.sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };

      xdg.desktopEntries.nvim = {
        name = "Neovim";
        genericName = "Text Editor";
        exec = "nvim-launch %F";
        icon = "nvim";
        categories = [ "Utility" "TextEditor" "Development" ];
        mimeType = [
          "text/plain"
          "text/markdown"
          "text/x-nix"
          "application/json"
          "application/x-shellscript"
        ];
        startupNotify = true;
      };

    };
}
