-- https://github.com/echasnovski/mini.statusline
return {
	"echasnovski/mini.statusline",
	version = "*",
	event = "VeryLazy",
	config = function()
		local statusline = require("mini.statusline")
		statusline.setup()
		statusline.section_location = function()
			return "%2l:%-2v"
		end
	end,
}
