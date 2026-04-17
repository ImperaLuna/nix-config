{ config, ... }:

{
  imports = import ../_lib/import-feature-tree.nix ./features;

  flake.modules.homeManager.terminal = {
    imports = [
      # Shell and session
      config.flake.modules.homeManager.terminal-feature-fish
      config.flake.modules.homeManager.terminal-feature-starship
      config.flake.modules.homeManager.terminal-feature-zoxide
      config.flake.modules.homeManager.terminal-feature-direnv

      # Core CLI tools
      config.flake.modules.homeManager.terminal-feature-bat
      config.flake.modules.homeManager.terminal-feature-eza
      config.flake.modules.homeManager.terminal-feature-fd
      config.flake.modules.homeManager.terminal-feature-file
      config.flake.modules.homeManager.terminal-feature-home-manager
      config.flake.modules.homeManager.terminal-feature-ripgrep
      config.flake.modules.homeManager.terminal-feature-fzf
      config.flake.modules.homeManager.terminal-feature-tealdeer

      # Git and diffs
      config.flake.modules.homeManager.terminal-feature-delta
      config.flake.modules.homeManager.terminal-feature-lazygit

      # Terminal apps and monitoring
      config.flake.modules.homeManager.terminal-feature-btop
      config.flake.modules.homeManager.terminal-feature-witr

      # Editor and file manager
      config.flake.modules.homeManager.terminal-feature-nvim
      config.flake.modules.homeManager.terminal-feature-yazi

      # AI/code assistants
      config.flake.modules.homeManager.terminal-feature-llm-cli-tools
    ];
  };
}
