{ ... }:

{
  flake.modules.homeManager.terminal-feature-zoxide = {
    programs.zoxide = {
      enable = true;
      enableFishIntegration = true;
      options = [ "--cmd" "cd" ];
    };
  };
}
