{ mkHome, ... }:

{
  Windows = mkHome {
    username = "rbrezeanu";
    homeDirectory = "/home/rbrezeanu";
    userConfig = ../../../modules/credentials/rbrezeanu;
    extraModules = [
      ({ lib, pkgs, ... }: {
        home.sessionVariables = {
          HM_CONFIG_NAME = "Windows";
          EDITOR = "nvim";
          VISUAL = "nvim";
        };

        home.packages = [
          pkgs.awscli2
          pkgs.docker
        ];

        programs.fish.shellInit = lib.mkAfter ''
          # WSL imports Windows PATH entries verbatim. Some installers add an
          # executable instead of its parent directory, which makes fish command
          # lookup fail with "component ... is not a directory".
          set -l clean_path
          for path_entry in "$HOME/.local/bin" "$HOME/.nix-profile/bin" /nix/var/nix/profiles/default/bin $PATH
            contains -- "$path_entry" $clean_path
            and continue

            if test ! -e "$path_entry"; or test -d "$path_entry"
              set -a clean_path "$path_entry"
            end
          end
          set -gx PATH $clean_path

          set -gx HM_CONFIG_NAME Windows
          set -gx EDITOR nvim
          set -gx VISUAL nvim
        '';
      })
    ];
  };
}
