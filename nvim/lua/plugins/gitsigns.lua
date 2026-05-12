-- https://github.com/lewis6991/gitsigns.nvim
return {
	"lewis6991/gitsigns.nvim",
	event = "BufRead",
	opts = {
		signs = {
			add          = { text = "┃" },
			change       = { text = "┃" },
			delete       = { text = "_" },
			topdelete    = { text = "‾" },
			changedelete = { text = "~" },
			untracked    = { text = "┆" },
		},
		signcolumn     = true,
		sign_priority  = 6,
		word_diff      = false,
		current_line_blame = true,
		current_line_blame_opts = {
			virt_text = true,
			virt_text_pos = "eol",
			delay = 500,
		},
		diff_opts = { internal = true },
	},
}
