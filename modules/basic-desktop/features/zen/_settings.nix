{
  "zen.window-sync.enabled" = true;
  "zen.window-sync.sync-only-pinned-tabs" = true;
  "browser.uiCustomization.state" = builtins.toJSON {
    placements = {
      "widget-overflow-fixed-list" = [ ];
      "unified-extensions-area" = [ ];
      "nav-bar" = [
        "back-button"
        "forward-button"
        "stop-reload-button"
        "customizableui-special-spring1"
        "vertical-spacer"
        "urlbar-container"
        "customizableui-special-spring2"
        "unified-extensions-button"
        "ublock0_raymondhill_net-browser-action"
        "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action"
      ];
      "toolbar-menubar" = [ "menubar-items" ];
      "TabsToolbar" = [ "tabbrowser-tabs" ];
      "vertical-tabs" = [ ];
      "PersonalToolbar" = [ "import-button" "personal-bookmarks" ];
      "zen-sidebar-top-buttons" = [ "zen-toggle-compact-mode" ];
      "zen-sidebar-foot-buttons" = [ "downloads-button" "zen-workspaces-button" "zen-create-new-button" ];
    };
    seen = [
      "developer-button"
      "screenshot-button"
      "ublock0_raymondhill_net-browser-action"
      "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action"
    ];
    dirtyAreaCache = [
      "nav-bar"
      "vertical-tabs"
      "zen-sidebar-foot-buttons"
      "PersonalToolbar"
      "unified-extensions-area"
      "toolbar-menubar"
      "TabsToolbar"
      "zen-sidebar-top-buttons"
    ];
    currentVersion = 23;
    newElementCount = 2;
  };
}
