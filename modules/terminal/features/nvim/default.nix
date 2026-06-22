{ ... }:

{
  flake.modules.homeManager.terminal-feature-nvim = { pkgs, ... }:
    let
      nvim = pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped {
        withPython3 = true;
        withNodeJs = false;
        withRuby = false;
        withPerl = false;
        viAlias = true;
        vimAlias = true;
        wrapRc = false;
      };
      nvimLauncher = pkgs.writeShellScriptBin "nvim-launch" ''
        exec ${pkgs.ghostty}/bin/ghostty -e ${nvim}/bin/nvim "$@"
      '';
    in
    {
      home.packages = [
        pkgs.nodejs
        pkgs.gcc
        nvim
        nvimLauncher
      ];

      home.sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };

      home.shellAliases = {
        vi = "nvim";
        vim = "nvim";
      };

      xdg.configFile."nvim/init.lua".source = ./assets/init.lua;
      xdg.configFile."nvim/lazyvim.json".source = ./assets/lazyvim.json;
      xdg.configFile."nvim/lua/plugins/colorscheme.lua".source =
        ./assets/lua/plugins/colorscheme.lua;

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
