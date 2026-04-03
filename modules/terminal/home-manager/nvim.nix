{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
  };

  home.packages = with pkgs; [
    # LazyVim dependencies
    nodejs
    gcc
  ];

  xdg.configFile."nvim/init.lua".source =
    ../../../home/terminal/modules/nvim/assets/init.lua;
  xdg.configFile."nvim/lazyvim.json".source =
    ../../../home/terminal/modules/nvim/assets/lazyvim.json;
  xdg.configFile."nvim/lua/plugins/colorscheme.lua".source =
    ../../../home/terminal/modules/nvim/assets/lua/plugins/colorscheme.lua;
}
