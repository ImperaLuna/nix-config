{ lib, ... }:

{
  flake.modules.homeManager.terminal-feature-claude-remote-control = { pkgs, ... }:
    let
      # Service name -> label and working directory.
      projects = {
        claude-remote-control = { label = "Nova"; dir = "%h/Projects/Nova"; };
        claude-remote-control-ummon = { label = "Ummon"; dir = "%h/Projects/DataAnnotation/Ummon-STA-4"; };
      };
    in
    {
      systemd.user.services = lib.mapAttrs (name: project: {
        Unit = {
          Description = "Claude Code remote control (${project.label})";
          After = [ "network-online.target" ];
          Wants = [ "network-online.target" ];
        };
        Service = {
          WorkingDirectory = project.dir;
          # Login shell, so PATH and the claude binary match the interactive shell.
          ExecStart = ''${pkgs.bash}/bin/bash -lc "claude remote-control"'';
          Restart = "always";
          RestartSec = 10;
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      }) projects;
    };
}
