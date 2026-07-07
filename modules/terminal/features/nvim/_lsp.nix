{ ... }:

{
  programs.nixvim = {
    diagnostic.settings = {
      virtual_text = {
        prefix = "●";
        spacing = 2;
        source = "if_many";
      };
      signs = true;
      underline = true;
      update_in_insert = false;
      severity_sort = true;
      float = {
        border = "rounded";
        source = "if_many";
      };
    };

    plugins.lsp = {
      enable = true;
      servers.ty.enable = true;
    };
  };
}
