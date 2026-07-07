{ config, ... }:

let
  grammars = config.programs.nixvim.plugins.treesitter.package.builtGrammars;
in
{
  programs.nixvim.plugins = {
    snacks = {
      enable = true;
      settings = {
        picker.enabled = true;
        notifier.enabled = true;
        input.enabled = true;
      };
    };

    which-key.enable = true;

    noice = {
      enable = true;
      settings = {
        cmdline = {
          enabled = true;
          view = "cmdline_popup";
        };
        popupmenu.enabled = true;
        views.cmdline_popup.position = {
          row = "25%";
          col = "50%";
        };
        messages.enabled = false;
        notify.enabled = false;
      };
    };

    mini = {
      enable = true;
      modules.pairs = { };
    };

    lualine = {
      enable = true;
      settings = {
        options = {
          theme = "auto";
          globalstatus = true;
          component_separators = {
            left = "";
            right = "";
          };
          section_separators = {
            left = "";
            right = "";
          };
        };
        sections = {
          lualine_a = [ "mode" ];
          lualine_b = [
            "branch"
            "diff"
          ];
          lualine_c = [ "filename" ];
          lualine_x = [
            "diagnostics"
            "filetype"
          ];
          lualine_y = [ "progress" ];
          lualine_z = [ "location" ];
        };
      };
    };

    bufferline = {
      enable = true;
      settings.options = {
        mode = "buffers";
        always_show_bufferline = true;
        diagnostics = "nvim_lsp";
        separator_style = "thin";
        show_buffer_close_icons = true;
        show_close_icon = false;
      };
    };

    diffview.enable = true;

    treesitter = {
      enable = true;
      grammarPackages = with grammars; [
        python
        lua
        vim
        vimdoc
        regex
        bash
        markdown
        markdown_inline
        nix
        json
      ];
      highlight.enable = true;
      indent.enable = true;
    };

    treesitter-textobjects = {
      enable = true;
      settings = {
        select = {
          lookahead = true;
          selection_modes = {
            "@function.outer" = "V";
            "@class.outer" = "V";
          };
        };
        move.set_jumps = true;
      };
    };

    neogit = {
      enable = true;
      settings = {
        kind = "floating";
        integrations.diffview = true;
      };
    };

    gitsigns = {
      enable = true;
      settings = {
        signcolumn = true;
        numhl = true;
        linehl = false;
        word_diff = false;
        current_line_blame = true;
        signs = {
          add.text = "▎";
          change.text = "▎";
          delete.text = "";
          topdelete.text = "";
          changedelete.text = "▎";
          untracked.text = "▎";
        };
      };
    };
  };
}
