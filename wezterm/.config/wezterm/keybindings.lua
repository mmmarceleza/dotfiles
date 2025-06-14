local wezterm = require("wezterm")
local act = wezterm.action
local keybindings = {
	{ key = "(", mods = "CTRL|SHIFT", action = act({ SplitHorizontal = { domain = "CurrentPaneDomain" } }) },
	{ key = ")", mods = "CTRL|SHIFT", action = act({ SplitVertical = { domain = "CurrentPaneDomain" } }) },
	{ key = "RightArrow", mods = "SHIFT", action = act({ ActivateTabRelative = 1 }) },
	{ key = "LeftArrow", mods = "SHIFT", action = act({ ActivateTabRelative = -1 }) },
	{ key = "F11", action = act.ToggleFullScreen },
	{ key = "[", mods = "LEADER", action = act.ActivateCopyMode },
	{ key = "e", mods = "CTRL|SHIFT", action = act.TogglePaneZoomState },
	{ key = "w", mods = "LEADER", action = act.ShowTabNavigator },
	{ key = "&", mods = "LEADER|SHIFT", action = act.CloseCurrentTab({ confirm = true }) },
	{ key = "j", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Down", 3 }) },
	{ key = "k", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Up", 3 }) },
	{ key = "h", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Left", 3 }) },
	{ key = "l", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Right", 3 }) },
	{ key = "q", mods = "CTRL|SHIFT", action = wezterm.action.QuitApplication },
	{ key = "{", mods = "CTRL|SHIFT", action = act.MoveTabRelative(-1) },
	{ key = "}", mods = "CTRL|SHIFT", action = act.MoveTabRelative(1) },
	{
		key = "s",
		mods = "CTRL|ALT",
		action = act.PromptInputLine({
			description = "Enter new name for tab",
			action = wezterm.action_callback(function(window, pane, line)
				-- line will be `nil` if they hit escape without entering anything
				-- An empty string if they just hit enter
				-- Or the actual line of text they wrote
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},

	-- Switch to the default workspace
	{
		key = "y",
		mods = "CTRL|SHIFT",
		action = act.SwitchToWorkspace({
			name = "default",
		}),
	},
	-- Create a new workspace with a random name and switch to it
	{ key = "i", mods = "CTRL|SHIFT", action = act.SwitchToWorkspace },
	-- Show the launcher in fuzzy selection mode and have it list all workspaces
	-- and allow activating one.
	{
		key = "w",
		mods = "LEADER",
		action = act.ShowLauncherArgs({
			flags = "FUZZY|WORKSPACES",
		}),
	},
}

return keybindings
