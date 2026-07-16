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

    flash.enable = true;

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

    blink-cmp = {
      enable = true;
      setupLspCapabilities = true;
      settings = {
        keymap = {
          preset = "default";
          "<C-space>" = [
            "show"
            "show_documentation"
            "hide_documentation"
          ];
          "<C-e>" = [ "hide" ];
          "<C-y>" = [ "select_and_accept" ];
        };
        sources.default = [
          "lsp"
          "path"
          "buffer"
        ];
        completion = {
          list.selection = {
            preselect = false;
            auto_insert = false;
          };
          accept.auto_brackets.semantic_token_resolution.enabled = false;
        };
        fuzzy.prebuilt_binaries.download = false;
        signature.enabled = true;
        appearance.nerd_font_variant = "normal";
      };
    };

    mini = {
      enable = true;
      modules = {
        ai = { };
        pairs = { };
        surround.mappings = {
          add = "gza";
          delete = "gzd";
          find = "gzf";
          find_left = "gzF";
          highlight = "gzh";
          replace = "gzr";
          update_n_lines = "gzn";
        };
      };
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

    grug-far = {
      enable = true;
      settings = {
        engine = "ripgrep";
        engines.ripgrep = {
          path = "rg";
          showReplaceDiff = true;
        };
      };
    };

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

    treesitter-context = {
      enable = true;
      settings = {
        max_lines = 2;
        line_numbers = true;
        multiline_threshold = 1;
        trim_scope = "inner";
        mode = "topline";
        separator = "─";
      };
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
        kind = "tab";
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

    todo-comments = {
      enable = true;
      settings = {
        signs = true;
        keywords = {
          NOTE.alt = config.lib.nixvim.emptyTable;
          WARN.alt = config.lib.nixvim.emptyTable;
        };
        highlight = {
          keyword = "bg";
          after = "fg";
          comments_only = true;
          pattern = ".*<(KEYWORDS)>";
        };
        search.pattern = "\\b(KEYWORDS)\\b";
      };
    };

    ts-comments.enable = true;

  };
}
