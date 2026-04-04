{ ... }:

{
  flake.modules.homeManager.terminal-feature-nvim = { pkgs, ... }: {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
    };

    home.packages = with pkgs; [
      nodejs
      gcc
    ];

    xdg.configFile."nvim/init.lua".source = ./assets/init.lua;
    xdg.configFile."nvim/lazyvim.json".source = ./assets/lazyvim.json;
    xdg.configFile."nvim/lua/plugins/colorscheme.lua".source =
      ./assets/lua/plugins/colorscheme.lua;
  };
}
