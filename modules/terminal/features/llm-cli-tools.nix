{ ... }:

{
  flake.modules.homeManager.terminal-feature-llm-cli-tools = {
    imports = [ ../home-manager/llm-cli-tools.nix ];
  };
}
