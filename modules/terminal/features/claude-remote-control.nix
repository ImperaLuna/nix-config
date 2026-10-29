{ ... }:

{
  flake.modules.homeManager.terminal-feature-claude-remote-control = { pkgs, ... }:
    {
      # One machine-wide remote control, so remote sessions can run commands
      # anywhere. It starts in ~/Remote because claude never saves trust for
      # $HOME, and project folders belong to Claude Desktop: a folder can only
      # be registered once, and a second claim fails with folder_taken.
      # Remote session names start with the hostname.
      systemd.user.tmpfiles.rules = [ "d %h/Remote 0755 - - -" ];

      systemd.user.services.claude-remote-connect = {
        Unit = {
          Description = "Claude Remote Connect: lets remote Claude sessions run commands on this PC";
          After = [ "network-online.target" ];
          Wants = [ "network-online.target" ];
        };
        Service = {
          WorkingDirectory = "%h/Remote";
          # Login shell, so PATH and the claude binary match the interactive shell.
          # No pre-created session: each start would add one, and it is left
          # behind with a deleted environment after every restart.
          ExecStart = ''${pkgs.bash}/bin/bash -lc "claude remote-control --no-create-session-in-dir"'';
          Restart = "always";
          RestartSec = 10;
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
}
