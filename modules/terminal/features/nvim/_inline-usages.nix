{ pkgs, ... }:

{
  programs.nixvim = {
    extraPlugins = [ pkgs.vimPlugins.symbol-usage-nvim ];

    extraConfigLua = ''
      do
        local SymbolKind = vim.lsp.protocol.SymbolKind

        require("symbol-usage").setup({
          kinds = {
            SymbolKind.Class,
            SymbolKind.Function,
            SymbolKind.Method,
          },
          vt_position = "end_of_line",
          request_pending_text = false,
          references = {
            enabled = true,
            include_declaration = false,
          },
          definition = { enabled = false },
          implementation = { enabled = false },
        })
      end
    '';
  };
}
