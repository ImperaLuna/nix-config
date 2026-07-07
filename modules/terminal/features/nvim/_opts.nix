{ ... }:

{
  programs.nixvim.opts = {
    number = true;
    relativenumber = true;
    ignorecase = true;
    smartcase = true;
    signcolumn = "yes";
    clipboard = "unnamedplus";
    expandtab = true;
    shiftwidth = 4;
    softtabstop = 4;
    tabstop = 4;
    termguicolors = true;
    timeoutlen = 1000;
    updatetime = 250;
  };
}
