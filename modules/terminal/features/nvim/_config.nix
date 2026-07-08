{ pkgs, ... }:

{
  imports = [
    ./_keymaps.nix
    ./_inline-usages.nix
    ./_lsp.nix
    ./_opts.nix
    ./_plugins.nix
    ./_theme.nix
  ];

  programs.nixvim = {
    enable = true;
    package = pkgs.neovim-unwrapped;
    viAlias = true;
    vimAlias = true;
    withPython3 = true;
    withRuby = false;
  };
}
