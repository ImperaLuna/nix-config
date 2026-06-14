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
    in
    {
      home.packages = [
        pkgs.nodejs
        pkgs.gcc
        # Avoid Home Manager's programs.neovim module here. Upstream currently
        # breaks on the empty-plugin case, while this setup manages Neovim via
        # XDG config files and does not use HM plugin declarations.
        nvim
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
        exec = "ghostty -e nvim %F";
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

      home.file.".local/share/applications/nvim.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=Neovim
        GenericName=Text Editor
        Exec=ghostty -e nvim %F
        Icon=nvim
        Categories=Utility;TextEditor;Development;
        MimeType=text/plain;text/markdown;text/x-nix;application/json;application/x-shellscript;
        StartupNotify=true
      '';
    };
}
