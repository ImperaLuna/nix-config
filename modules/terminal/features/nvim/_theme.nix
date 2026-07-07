{ ... }:

let
  theme = import ../../../_lib/theme.nix;
in
{
  programs.nixvim.extraConfigLua = ''
    local palette = vim.json.decode([[${builtins.toJSON theme}]])
  '' + builtins.readFile ./assets/carbox-fox.lua;
}
