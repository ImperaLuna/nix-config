# ── External packages (not in nixpkgs — update rev + hash manually) ──────────
#  fifc
#  modules/fish/fish.nix
#  github:gazorby/fifc@a01650cd
# ─────────────────────────────────────────────────────────────────────────────
#  fish-abbreviation-tips
#  modules/fish/fish.nix
#  github:gazorby/fish-abbreviation-tips@8ed76a62
# ─────────────────────────────────────────────────────────────────────────────

{ lib, config, ... }:

{
  imports = [
    ./modules/bat/bat.nix
    ./modules/btop/btop.nix
    ./modules/delta/delta.nix
    ./modules/direnv/direnv.nix
    ./modules/duf/duf.nix
    ./modules/dust/dust.nix
    ./modules/eza/eza.nix
    ./modules/fd/fd.nix
    ./modules/file/file.nix
    ./modules/fish/fish.nix
    ./modules/fzf/fzf.nix
    ./modules/lazygit/lazygit.nix
    ./modules/nvim/nvim.nix
    ./modules/ripgrep/ripgrep.nix
    ./modules/starship/starship.nix
    ./modules/tealdeer/tealdeer.nix
    ./modules/tmux/tmux.nix
    ./modules/witr/witr.nix
    ./modules/yazi/yazi.nix
    ./modules/zoxide/zoxide.nix

    # ── LLM / AI CLI tools ──────────────────────────────────────────────────
    ./modules/llm_cli_tools/llm_cli_tools.nix

    # ── Extras (temporary / experimental packages) ───────────────────────────
    ./extras.nix
  ];

  options.modules.terminal.enable = lib.mkEnableOption "terminal tools";

  config = lib.mkIf config.modules.terminal.enable {
    modules = {
      bat.enable      = true;
      btop.enable     = true;
      delta.enable    = true;
      direnv.enable   = true;
      duf.enable      = true;
      dust.enable     = true;
      eza.enable      = true;
      fd.enable       = true;
      file.enable     = true;
      fish.enable     = true;
      fzf.enable      = true;
      lazygit.enable  = true;
      nvim.enable     = true;
      ripgrep.enable  = true;
      starship.enable = true;
      tealdeer.enable = true;
      tmux.enable     = true;
      witr.enable     = true;
      yazi.enable     = true;
      zoxide.enable   = true;

      # ── LLM / AI CLI tools ──────────────────────────────────────────────────
      llm_cli_tools.claude-code = true;
      llm_cli_tools.codex       = true;
    };
  };
}
