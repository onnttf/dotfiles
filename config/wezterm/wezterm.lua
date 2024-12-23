-- Pull in the wezterm API
local wezterm = require("wezterm")
-- Configuration table
local config = {}

-- Use config_builder for clearer error messages in newer wezterm versions
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- Enable automatic checking for updates
config.check_for_updates = true
-- Set the interval for checking updates to once a day (in seconds)
config.check_for_updates_interval_seconds = 86400

-- Hide the tab bar if only one tab is open
config.hide_tab_bar_if_only_one_tab = true

-- Configure window padding
config.window_padding = {
	left = 2,
	right = 2,
	top = 2,
	bottom = 2,
}

-- Set the background opacity for the window
config.window_background_opacity = 0.85

-- Configure HarfBuzz features for text rendering
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }

-- Alias for wezterm.action for brevity
local act = wezterm.action

-- Define keybindings for various actions
config.keys = {
	-- Split the current pane horizontally
	{ key = "|", mods = "CMD", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	-- Split the current pane vertically
	{ key = "_", mods = "CMD", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	-- Close the current pane
	{ key = "C", mods = "CMD", action = act.CloseCurrentPane({ confirm = false }) },
	-- Activate the pane to the left
	{ key = "h", mods = "CMD", action = act.ActivatePaneDirection("Left") },
	-- Activate the pane to the right
	{ key = "l", mods = "CMD", action = act.ActivatePaneDirection("Right") },
	-- Activate the pane above
	{ key = "j", mods = "CMD", action = act.ActivatePaneDirection("Up") },
	-- Activate the pane below
	{ key = "k", mods = "CMD", action = act.ActivatePaneDirection("Down") },
	-- Move the current tab to the left
	{ key = "<", mods = "CMD", action = act.MoveTabRelative(-1) },
	-- Move the current tab to the right
	{ key = ">", mods = "CMD", action = act.MoveTabRelative(1) },
}

-- Return the configuration to wezterm
return config
