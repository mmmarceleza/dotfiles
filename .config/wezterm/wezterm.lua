local wezterm = require("wezterm")

local colors = require("colors")
local keybindings = require("keybindings")
local statusline = require("statusline")
local workspaces = require("workspaces")
local config = {}

config.colors = colors
config.keys = keybindings
config.leader = { key = "s", mods = "CTRL", timeout_milliseconds = 2000 }
config.default_prog = { "/usr/bin/zsh" }
config.color_scheme = "Tango (terminal.sexy)"
config.font = wezterm.font("JetBrains Mono")
config.font_size = 16
config.scrollback_lines = 99999
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.switch_to_last_active_tab_when_closing_tab = true
config.tab_max_width = 32
config.window_decorations = "RESIZE"
config.hide_mouse_cursor_when_typing = false
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
-- config.inactive_pane_hsb = { saturation = 0.1, brightness = 0.5 }
config.audible_bell = "Disabled"
config.visual_bell = {
  fade_in_function = 'EaseIn',
  fade_in_duration_ms = 150,
  fade_out_function = 'EaseOut',
  fade_out_duration_ms = 150,
}
config.colors = {
  visual_bell = '#202020',
}

return config
