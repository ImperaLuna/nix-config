{ ... }:

{
  flake.modules.homeManager.terminal-feature-nvim = { pkgs, ... }: {
    home.packages =
      with pkgs;
      [
        nodejs
        gcc
        # Avoid Home Manager's programs.neovim module here. Upstream currently
        # breaks on the empty-plugin case, while this setup manages Neovim via
        # XDG config files and does not use HM plugin declarations.
        (wrapNeovimUnstable neovim-unwrapped {
          withPython3 = true;
          withNodeJs = false;
          withRuby = false;
          withPerl = false;
          viAlias = true;
          vimAlias = true;
          wrapRc = false;
        })
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
  };
}
