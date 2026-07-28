{ inputs, lib, pkgs, ... }:

{
  home.packages = [
    inputs.iris.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  xdg.configFile."iris/config.toml".text = ''
    [core]
    version = 1
    shell = "zsh"
    mode = "last"
    debug = false

    [ui]
    style = "modern"
    ghost-text = true
    max-suggestions = 100
    max-height = 15
    nerd-fonts = true

    [git]
    filter-active-branch = true
    deduplicate-branches = true

    [updater]
    check-on-startup = false
    channel = "stable"
    check-interval = "24h"
  '';

  programs.zsh.initContent = lib.mkAfter ''
    if [[ -o interactive && -t 0 && -t 1 && -z "''${IRIS_PID:-}" ]] && (( $+commands[iris] )); then
      exec iris
    fi
  '';
}
