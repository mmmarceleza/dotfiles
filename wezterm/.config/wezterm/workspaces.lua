local wezterm = require 'wezterm'
local mux = wezterm.mux

wezterm.on('gui-startup', function(cmd)
  -- creates a default window but makes it maximize on startup
  local tab, pane, window = mux.spawn_window(cmd or {})
  window:gui_window():maximize()

end)

return {}
