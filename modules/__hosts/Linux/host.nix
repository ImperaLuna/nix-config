{ mkHome, ... }:

{
  Linux = mkHome {
    username = "root";
    homeDirectory = "/root";
    userConfig = ../.users/imperaluna;
    extraModules = [
      {
        home.sessionPath = [
          "$HOME/.nix-profile/bin"
          "/nix/var/nix/profiles/default/bin"
        ];

        home.sessionVariables = {
          HM_CONFIG_NAME = "Linux";
          EDITOR = "nvim";
          VISUAL = "nvim";
        };
      }
    ];
  };
}
