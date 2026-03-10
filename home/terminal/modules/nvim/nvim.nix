{ pkgs, lib, config, ... }:

{
  options.modules.nvim.enable = lib.mkEnableOption "nvim";

  config = lib.mkIf config.modules.nvim.enable {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
    };

    home.packages = with pkgs; [
      # LazyVim dependencies
      nodejs # for LSP servers
      gcc    # for treesitter compilation
    ];

    xdg.configFile."nvim/init.lua".source = ./assets/init.lua;
    xdg.configFile."nvim/lazyvim.json".source = ./assets/lazyvim.json;
    xdg.configFile."nvim/lua/plugins/colorscheme.lua".source =
      ./assets/lua/plugins/colorscheme.lua;
  };
}
