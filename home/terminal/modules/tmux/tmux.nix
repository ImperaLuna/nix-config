{ pkgs, lib, config, ... }:

{
  options.modules.tmux.enable = lib.mkEnableOption "tmux";

  config = lib.mkIf config.modules.tmux.enable {
    programs.tmux = {
      enable = true;
      mouse = true;
      baseIndex = 1;
      escapeTime = 0;
      historyLimit = 10000;
      terminal = "tmux-256color";

      plugins = with pkgs.tmuxPlugins; [
        catppuccin
      ];

      extraConfig = ''
        set -ag terminal-overrides ",xterm-256color:RGB"
        set -g pane-base-index 1
        set -g renumber-windows on

        # Pass extended key sequences (Ctrl+/, Ctrl+Alt+* etc.) through
        set -s extended-keys on
        set -as terminal-features 'xterm*:extkeys'

        # ── Keybindings ───────────────────────────────────────────────────

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

        # ── Catppuccin ────────────────────────────────────────────────────

        set -g @catppuccin_flavor 'mocha'

        set -g status-left ""
        set -g status-right '#[fg=#{@thm_crust},bg=#{@thm_mauve}]  #S '
        set -g status-right-length 100
      '';
    };
  };
}
