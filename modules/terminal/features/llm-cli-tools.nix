{ ... }:

{
  flake.modules.homeManager.terminal-feature-llm-cli-tools = { pkgs, ... }: {
    home.packages = [
      pkgs.claude-code
      pkgs.codex
      pkgs.opencode
    ];
  };
}
