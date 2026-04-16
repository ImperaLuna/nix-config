local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.enable_kitty_keyboard = true

config.colors = {
  selection_fg = '#11111b', -- black
  selection_bg = '#00ADB5', -- teal
}

config.font = wezterm.font('JetBrainsMono Nerd Font')
config.font_size = 13.0

return config
