{ ... }:

{
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      auto_sync = false;
      store_failed = true;
      search_mode = "fuzzy";
      filter_mode = "global";
      filter_mode_shell_up_key_binding = "directory";
      style = "auto";
      inline_height = 20;
      enter_accept = false;
      show_preview = true;
      max_preview_height = 4;
    };
  };
}
