{ ... }:

{
  flake.modules.homeManager.terminal-feature-gh = { pkgs, ... }: {
    home.packages = [ pkgs.gh ];

    # git over HTTPS takes GitHub credentials from gh, as `gh auth setup-git`
    # would set up, since home-manager's git config is read-only. The empty
    # entry drops any helper set before it.
    programs.git.settings.credential = builtins.listToAttrs (map (host: {
      name = "https://${host}";
      value.helper = [ "" "!${pkgs.gh}/bin/gh auth git-credential" ];
    }) [ "github.com" "gist.github.com" ]);
  };
}
