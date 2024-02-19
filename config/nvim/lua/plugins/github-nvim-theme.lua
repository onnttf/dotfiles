-- https://github.com/projekt0n/github-nvim-theme

require("github-theme").setup({
	options = {
		-- Enable transparent background
		transparent = true,
	},
})

-- Set the color scheme to GitHub Dark
vim.cmd([[colorscheme github_dark]])
