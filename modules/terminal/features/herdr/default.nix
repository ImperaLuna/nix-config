{
  flake.modules.homeManager.terminal-feature-herdr = { lib, pkgs, ... }:
    let
      # herdr's zsh completion takes session names as free text. This copy
      # completes them for `session attach/stop/delete` and `--session`. It
      # patches a copy of the file, so herdr itself is not rebuilt.
      herdrCompletion = pkgs.runCommand "herdr-zsh-completion" { } ''
        dir=$out/share/zsh/site-functions
        mkdir -p $dir
        ${pkgs.gawk}/bin/awk '
          /herdr-session-command-/ { session = 1 }
          /^\(integration\)$/ { session = 0 }
          session { gsub(/:name:_default/, ":name:_herdr_session_names") }
          { sub(/persistent session\]:NAME:_default/, "persistent session]:NAME:_herdr_session_names") }
          { print }
        ' ${pkgs.herdr}/share/zsh/site-functions/_herdr > $dir/_herdr
        # Fail the build if a herdr update moves the lines this relies on.
        test "$(grep -c _herdr_session_names $dir/_herdr)" -eq 4
        substitute ${./_herdr_session_names} $dir/_herdr_session_names \
          --replace-fail @jq@ ${pkgs.jq}/bin/jq
      '';
    in
    {
      home.packages = [ pkgs.herdr ];

      # Read-only once linked, so herdr's settings screen can't save changes.
      # Edit here instead, then `herdr server reload-config`.
      xdg.configFile."herdr/config.toml".text = ''
        onboarding = false

        [keys]
        prefix = "ctrl+space"

        [ui]
        agent_panel_sort = "spaces"

        [theme]
        name = "vesper"
        auto_switch = false
      '';

      # Ahead of herdr's own copy. /etc/zshrc has already run compinit, which
      # bound _herdr to herdr's file, so drop that binding and autoload again.
      programs.zsh.initContent = lib.mkOrder 550 ''
        fpath=(${herdrCompletion}/share/zsh/site-functions $fpath)
        unfunction _herdr 2>/dev/null
        autoload -Uz _herdr
      '';
    };
}
