{ ... }:

{
  flake.modules.homeManager.terminal-feature-claude-remote-control = { pkgs, ... }:
    {
      # One machine-wide remote control in $HOME, so remote sessions can run
      # commands anywhere. Project folders belong to Claude Desktop instead: a
      # folder can only be registered once, and a second claim fails with
      # folder_taken. Session names default to the hostname.
      systemd.user.services.claude-remote-control = {
        Unit = {
          Description = "Claude Code remote control (RyzenShine)";
          After = [ "network-online.target" ];
          Wants = [ "network-online.target" ];
        };
        Service = {
          WorkingDirectory = "%h";
          # Login shell, so PATH and the claude binary match the interactive shell.
          ExecStart = ''${pkgs.bash}/bin/bash -lc "claude remote-control"'';
          Restart = "always";
          RestartSec = 10;
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
}
