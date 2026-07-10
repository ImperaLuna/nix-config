{ ... }:

let
  saveCurrentBuffer = "<cmd>lua if vim.bo.buftype == '' and vim.bo.modifiable and not vim.bo.readonly and vim.api.nvim_buf_get_name(0) ~= '' then vim.cmd('update') end<CR>";
in
{
  programs.nixvim = {
    globals = {
      mapleader = " ";
      maplocalleader = "\\";
    };

    keymaps = [
      {
        mode = "i";
        key = "<Esc>";
        action = "<Esc>${saveCurrentBuffer}";
        options.desc = "Exit Insert and Save";
      }
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
        key = "<leader>R";
        action = "<cmd>GrugFar<CR>";
        options.desc = "Search and Replace";
      }
      {
        mode = "x";
        key = "<leader>R";
        action = ":GrugFar<CR>";
        options.desc = "Search and Replace Selection";
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
        key = "gr";
        action = "<cmd>lua Snacks.picker.lsp_references()<CR>";
        options = {
          desc = "Goto References";
          nowait = true;
        };
      }
      {
        mode = "n";
        key = "gy";
        action = "<cmd>lua Snacks.picker.lsp_type_definitions()<CR>";
        options.desc = "Goto Type Definition";
      }
      {
        mode = "n";
        key = "<leader>ls";
        action = "<cmd>lua Snacks.picker.lsp_symbols()<CR>";
        options.desc = "Document Symbols";
      }
      {
        mode = "n";
        key = "<leader>lS";
        action = "<cmd>lua Snacks.picker.lsp_workspace_symbols()<CR>";
        options.desc = "Workspace Symbols";
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
        key = "<leader>ct";
        action = "<cmd>lua local buf_dir = vim.fn.expand('%:p:h'); local cwd = vim.fs.root(0, { '.git' }) or (vim.fn.isdirectory(buf_dir) == 1 and buf_dir or vim.fn.getcwd()); require('todo-comments.search').setqflist({ cwd = cwd })<CR>";
        options.desc = "Todo Quickfix";
      }
      {
        mode = "n";
        key = "]t";
        action = "<cmd>lua require('todo-comments').jump_next()<CR>";
        options.desc = "Next Todo Comment";
      }
      {
        mode = "n";
        key = "[t";
        action = "<cmd>lua require('todo-comments').jump_prev()<CR>";
        options.desc = "Previous Todo Comment";
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
        mode = [
          "n"
          "x"
        ];
        key = "<leader>y";
        action = "\"+y";
        options.desc = "Yank to Clipboard";
      }
      {
        mode = "n";
        key = "<leader>Y";
        action = "\"+Y";
        options.desc = "Yank Line to Clipboard";
      }
      {
        mode = [
          "n"
          "x"
        ];
        key = "<leader>p";
        action = "\"+p";
        options.desc = "Paste Clipboard";
      }
      {
        mode = [
          "n"
          "x"
        ];
        key = "<leader>P";
        action = "\"+P";
        options.desc = "Paste Clipboard Before";
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
      {
        mode = [
          "n"
          "x"
          "o"
        ];
        key = "s";
        action = "<cmd>lua require('flash').jump()<CR>";
        options.desc = "Flash Jump";
      }
      {
        mode = [
          "n"
          "x"
          "o"
        ];
        key = "S";
        action = "<cmd>lua require('flash').treesitter()<CR>";
        options.desc = "Flash Treesitter";
      }
      {
        mode = "o";
        key = "r";
        action = "<cmd>lua require('flash').remote()<CR>";
        options.desc = "Remote Flash";
      }
      {
        mode = [
          "o"
          "x"
        ];
        key = "R";
        action = "<cmd>lua require('flash').treesitter_search()<CR>";
        options.desc = "Flash Treesitter Search";
      }
    ];
  };
}
