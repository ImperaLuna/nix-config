{ ... }:

{
  programs.zed-editor = {
    enable = true;
    userSettings = {
      autosave = "on_focus_change";
      vim_mode = true;
    };
  };
}
