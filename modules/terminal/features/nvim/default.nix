{ inputs, ... }:

let
  theme = import ../../../_lib/theme.nix;
in
{
  flake.modules.homeManager.terminal-feature-nvim = { config, pkgs, ... }:
    let
      nvimLauncher = pkgs.writeShellScriptBin "nvim-launch" ''
        exec ${pkgs.ghostty}/bin/ghostty -e ${config.programs.nixvim.build.package}/bin/nvim "$@"
      '';
    in
    {
      imports = [ inputs.nixvim.homeModules.nixvim ];

      programs.nixvim = {
        enable = true;
        package = pkgs.neovim-unwrapped;
        viAlias = true;
        vimAlias = true;
        withPython3 = true;
        withRuby = false;

        globals = {
          mapleader = " ";
          maplocalleader = "\\";
        };

        opts = {
          number = true;
          relativenumber = true;
          signcolumn = "yes";
          termguicolors = true;
          timeoutlen = 400;
          updatetime = 250;
        };

        extraConfigLua = ''
          local palette = vim.json.decode([[${builtins.toJSON theme}]])
        '' + builtins.readFile ./assets/carbox-fox.lua;
      };

      home.packages = [ nvimLauncher ];

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
