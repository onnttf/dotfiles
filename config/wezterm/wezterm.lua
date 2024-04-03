-- Require the WezTerm module
local wezterm = require("wezterm")

-- Create an empty configuration table
local config = {}

-- If a configuration builder is available, use it to build the configuration
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- Enable checking for updates
config.check_for_updates = true

-- Set the interval for checking updates to one day (86400 seconds)
config.check_for_updates_interval_seconds = 86400

-- Hide the tab bar if there's only one tab
config.hide_tab_bar_if_only_one_tab = true

-- Set window padding
config.window_padding = {
	left = 4,
	right = 4,
	top = 4,
	bottom = 4,
}

-- Set window background opacity to 80%
config.window_background_opacity = 0.8

-- Set Harfbuzz features
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }

-- Define key bindings
config.keys = {
	-- Split the current pane horizontally
	{ key = "|", mods = "CMD", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	-- Split the current pane vertically
	{ key = "_", mods = "CMD", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
	-- Close the current pane
	{ key = "C", mods = "CMD", action = wezterm.action.CloseCurrentPane({ confirm = false }) },
	-- Activate the pane to the left
	{ key = "h", mods = "CMD", action = wezterm.action.ActivatePaneDirection("Left") },
	-- Activate the pane to the right
	{ key = "l", mods = "CMD", action = wezterm.action.ActivatePaneDirection("Right") },
	-- Activate the pane above
	{ key = "j", mods = "CMD", action = wezterm.action.ActivatePaneDirection("Up") },
	-- Activate the pane below
	{ key = "k", mods = "CMD", action = wezterm.action.ActivatePaneDirection("Down") },
	-- Move the current tab to the left
	{ key = "<", mods = "CMD", action = wezterm.action.MoveTabRelative(-1) },
	-- Move the current tab to the right
	{ key = ">", mods = "CMD", action = wezterm.action.MoveTabRelative(1) },
}

-- Return the configuration table
return config
