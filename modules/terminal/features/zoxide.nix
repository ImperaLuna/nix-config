{ ... }:

{
  flake.modules.homeManager.terminal-feature-zoxide = {
    programs.zoxide = {
      enable = true;
      options = [ "--cmd" "cd" ];
    };
  };
}
