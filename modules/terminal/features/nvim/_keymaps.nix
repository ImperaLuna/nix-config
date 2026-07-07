{ ... }:

{
  programs.nixvim = {
    globals = {
      mapleader = " ";
      maplocalleader = "\\";
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>f";
        action = "<cmd>lua Snacks.picker.files()<CR>";
        options.desc = "Find Files";
      }
      {
        mode = "n";
        key = "<leader>s";
        action = "<cmd>lua Snacks.picker.grep()<CR>";
        options.desc = "Search Text";
      }
      {
        mode = "n";
        key = "<leader>b";
        action = "<cmd>lua Snacks.picker.buffers()<CR>";
        options.desc = "Buffers";
      }
      {
        mode = "n";
        key = "gd";
        action = "<cmd>lua Snacks.picker.lsp_definitions()<CR>";
        options.desc = "Goto Definition";
      }
      {
        mode = "n";
        key = "K";
        action = "<cmd>lua vim.lsp.buf.hover()<CR>";
        options.desc = "Hover";
      }
      {
        mode = "n";
        key = "<leader>rn";
        action = "<cmd>lua vim.lsp.buf.rename()<CR>";
        options.desc = "Rename Symbol";
      }
      {
        mode = "n";
        key = "<leader>ca";
        action = "<cmd>lua vim.lsp.buf.code_action()<CR>";
        options.desc = "Code Action";
      }
      {
        mode = "n";
        key = "<leader>e";
        action = "<cmd>lua vim.diagnostic.open_float()<CR>";
        options.desc = "Line Diagnostic";
      }
      {
        mode = "n";
        key = "<leader>g";
        action = "<cmd>lua require('neogit').open()<CR>";
        options.desc = "Neogit";
      }
      {
        mode = "n";
        key = "]h";
        action = "<cmd>Gitsigns next_hunk<CR>";
        options.desc = "Next Git Hunk";
      }
      {
        mode = "n";
        key = "[h";
        action = "<cmd>Gitsigns prev_hunk<CR>";
        options.desc = "Previous Git Hunk";
      }
      {
        mode = "n";
        key = "<leader>gp";
        action = "<cmd>Gitsigns preview_hunk<CR>";
        options.desc = "Preview Git Hunk";
      }
      {
        mode = "n";
        key = "<leader>gw";
        action = "<cmd>Gitsigns toggle_word_diff<CR>";
        options.desc = "Toggle Git Word Diff";
      }
      {
        mode = "n";
        key = "H";
        action = "<cmd>bprevious<CR>";
        options.desc = "Previous Buffer";
      }
      {
        mode = "n";
        key = "L";
        action = "<cmd>bnext<CR>";
        options.desc = "Next Buffer";
      }
      {
        mode = "x";
        key = "p";
        action = "\"_dP";
        options.desc = "Paste Without Yanking Selection";
      }
      {
        mode = "n";
        key = "<C-a>";
        action = "ggVG";
        options.desc = "Select All";
      }
      {
        mode = "i";
        key = "<C-a>";
        action = "<Esc>ggVG";
        options.desc = "Select All";
      }
      {
        mode = [
          "x"
          "o"
        ];
        key = "af";
        action = "<cmd>lua require('nvim-treesitter-textobjects.select').select_textobject('@function.outer', 'textobjects')<CR>";
        options.desc = "Select Around Function";
      }
      {
        mode = [
          "x"
          "o"
        ];
        key = "if";
        action = "<cmd>lua require('nvim-treesitter-textobjects.select').select_textobject('@function.inner', 'textobjects')<CR>";
        options.desc = "Select Inside Function";
      }
      {
        mode = [
          "x"
          "o"
        ];
        key = "ac";
        action = "<cmd>lua require('nvim-treesitter-textobjects.select').select_textobject('@class.outer', 'textobjects')<CR>";
        options.desc = "Select Around Class";
      }
      {
        mode = [
          "x"
          "o"
        ];
        key = "ic";
        action = "<cmd>lua require('nvim-treesitter-textobjects.select').select_textobject('@class.inner', 'textobjects')<CR>";
        options.desc = "Select Inside Class";
      }
      {
        mode = [
          "n"
          "x"
          "o"
        ];
        key = "]f";
        action = "<cmd>lua require('nvim-treesitter-textobjects.move').goto_next_start('@function.outer', 'textobjects')<CR>";
        options.desc = "Next Function";
      }
      {
        mode = [
          "n"
          "x"
          "o"
        ];
        key = "[f";
        action = "<cmd>lua require('nvim-treesitter-textobjects.move').goto_previous_start('@function.outer', 'textobjects')<CR>";
        options.desc = "Previous Function";
      }
      {
        mode = [
          "n"
          "x"
          "o"
        ];
        key = "]c";
        action = "<cmd>lua require('nvim-treesitter-textobjects.move').goto_next_start('@class.outer', 'textobjects')<CR>";
        options.desc = "Next Class";
      }
      {
        mode = [
          "n"
          "x"
          "o"
        ];
        key = "[c";
        action = "<cmd>lua require('nvim-treesitter-textobjects.move').goto_previous_start('@class.outer', 'textobjects')<CR>";
        options.desc = "Previous Class";
      }
    ];
  };
}
