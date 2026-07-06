{ mkHome, ... }:

{
  Windows = mkHome {
    username = "rbrezeanu";
    homeDirectory = "/home/rbrezeanu";
    userConfig = ../../../modules/credentials/rbrezeanu;
    extraModules = [
      ({ lib, ... }: {
        home.sessionVariables = {
          HM_CONFIG_NAME = "Windows";
          EDITOR = "nvim";
          VISUAL = "nvim";
        };

        programs.fish.shellInit = lib.mkAfter ''
          set -gx HM_CONFIG_NAME Windows
          set -gx EDITOR nvim
          set -gx VISUAL nvim
        '';
      })
    ];
  };
}
