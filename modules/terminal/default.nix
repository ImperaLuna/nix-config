{ inputs, config, ... }:

{
  imports = [
    (inputs.import-tree ./features)
  ];

  flake.modules.homeManager.terminal-role-default = {
    imports = [
      config.flake.modules.homeManager.terminal-feature-bat
      config.flake.modules.homeManager.terminal-feature-btop
      config.flake.modules.homeManager.terminal-feature-delta
      config.flake.modules.homeManager.terminal-feature-direnv
      config.flake.modules.homeManager.terminal-feature-duf
      config.flake.modules.homeManager.terminal-feature-dust
      config.flake.modules.homeManager.terminal-feature-eza
      config.flake.modules.homeManager.terminal-feature-fd
      config.flake.modules.homeManager.terminal-feature-file
      config.flake.modules.homeManager.terminal-feature-fish
      config.flake.modules.homeManager.terminal-feature-fzf
      config.flake.modules.homeManager.terminal-feature-lazygit
      config.flake.modules.homeManager.terminal-feature-llm-cli-tools
      config.flake.modules.homeManager.terminal-feature-nvim
      config.flake.modules.homeManager.terminal-feature-ripgrep
      config.flake.modules.homeManager.terminal-feature-starship
      config.flake.modules.homeManager.terminal-feature-tealdeer
      config.flake.modules.homeManager.terminal-feature-tmux
      config.flake.modules.homeManager.terminal-feature-witr
      config.flake.modules.homeManager.terminal-feature-yazi
      config.flake.modules.homeManager.terminal-feature-zoxide
    ];
  };
}
