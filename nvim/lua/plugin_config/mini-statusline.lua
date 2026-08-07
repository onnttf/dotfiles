-- https://github.com/echasnovski/mini.statusline
return {
	"echasnovski/mini.statusline",
	version = "*",
	config = function()
		local statusline = require("mini.statusline")
		statusline.setup({
			content = {
				inactive = function()
					return "%#MiniStatuslineInactive# %t %="
				end,
			},
		})
		statusline.section_location = function()
			return "%2l:%-2v"
		end
	end,
}
