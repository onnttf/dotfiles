-- https://github.com/glepnir/dashboard-nvim
require("dashboard").setup({
	config = {
		-- Configuration options for the dashboard
		week_header = {
			enable = true,
		},
		-- Shortcut configuration for quick actions
		shortcut = {
			{
				icon = "  ",
				desc = "New File",
				key = "nf",
				action = "enew",
			},
			{
				icon = "  ",
				desc = "Find file",
				key = "ff",
				action = ":Telescope find_files",
			},
			{
				icon = "  ",
				desc = "Find Text",
				key = "ft",
				action = "Telescope live_grep",
			},
			{
				icon = "  ",
				desc = "Config",
				key = "c",
				action = ":e $MYVIMRC",
			},
			{
				icon = "  ",
				desc = "Quit",
				key = "q",
				action = "qa",
			},
		},

		-- Footer message displayed at the bottom of the dashboard
		footer = { "", "🎉 Meet a better version of yourself every day." },
	},
})
