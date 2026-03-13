{ lib, config, inputs, pkgs, ... }:

let
  cfg = config.modules.llm_cli_tools;
  llm = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in

{
  options.modules.llm_cli_tools = {
    claude-code = lib.mkEnableOption "claude-code";
    codex       = lib.mkEnableOption "codex";
    opencode    = lib.mkEnableOption "opencode";
    opencode-desktop = lib.mkEnableOption "opencode-desktop";
  };

  config = {
    home.packages =
      lib.optional cfg.claude-code llm.claude-code
      ++ lib.optional cfg.codex    llm.codex
      ++ lib.optional cfg.opencode pkgs.opencode
      ++ lib.optional cfg.opencode-desktop pkgs.opencode-desktop;
  };
}
