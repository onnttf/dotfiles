-- https://github.com/lukas-reineke/indent-blankline.nvim
require("ibl").setup({
	exclude = {
		filetypes = { "help", "git", "markdown", "snippets", "text", "gitconfig", "alpha", "dashboard" },
		buftypes = { "terminal" },
	},
})
