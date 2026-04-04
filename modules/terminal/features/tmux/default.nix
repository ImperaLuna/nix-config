{ self, inputs, ... }:

{
  perSystem = { pkgs, ... }: {
    packages.terminal-tmux = inputs.nix-wrapper-modules.wrappers.tmux.wrap {
      inherit pkgs;

      mouse = true;
      baseIndex = 1;
      escapeTime = 0;
      historyLimit = 10000;
      terminal = "tmux-256color";
      terminalOverrides = ",xterm-256color:RGB";
      paneBaseIndex = 1;

      plugins = with pkgs.tmuxPlugins; [
        catppuccin
      ];

      configAfter = ''
        set -g renumber-windows on

        # Pass extended key sequences (Ctrl+/, Ctrl+Alt+* etc.) through
        set -s extended-keys on
        set -as terminal-features 'xterm*:extkeys'

        # Keybindings
        unbind C-b
        set -g prefix C-Space
        bind C-Space send-prefix

        bind | split-window -h -c "#{pane_current_path}"
        bind - split-window -v -c "#{pane_current_path}"

        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R

        bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded"

        bind-key -n 'C-/' send-keys 'C-/'

        # Catppuccin
        set -g @catppuccin_flavor 'mocha'

        set -g status-left ""
        set -g status-right '#[fg=#{@thm_crust},bg=#{@thm_mauve}]  #S '
        set -g status-right-length 100
      '';
    };
  };

  flake.modules.homeManager.terminal-feature-tmux = { pkgs, ... }: {
    programs.tmux = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.terminal-tmux;
    };
  };
}
