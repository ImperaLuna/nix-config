{ lib, ... }:

{
  flake.modules.homeManager.terminal-feature-claude-remote-control = { pkgs, ... }:
    let
      # Service name -> working directory.
      projects = {
        claude-remote-control = "%h/Projects/Nova";
        claude-remote-control-ummon = "%h/Projects/DataAnnotation/Ummon-STA-4";
      };
    in
    {
      systemd.user.services = lib.mapAttrs (name: dir: {
        Unit = {
          Description = "Claude Code remote control in ${dir}";
          After = [ "network-online.target" ];
          Wants = [ "network-online.target" ];
        };
        Service = {
          WorkingDirectory = dir;
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
