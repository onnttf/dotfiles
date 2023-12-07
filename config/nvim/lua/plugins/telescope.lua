-- https://github.com/nvim-telescope/telescope.nvim
local actions = require("telescope.actions")
local telescope = require("telescope")

-- Configure Telescope defaults and pickers
telescope.setup({
	defaults = {
		mappings = {
			i = {
				["<C-u>"] = false,
				["<Tab>"] = actions.move_selection_previous,
				["<S-Tab>"] = actions.move_selection_next,
				["<C-j>"] = actions.move_selection_next,
				["<C-k>"] = actions.move_selection_previous,
			},
			n = {
				["<esc>"] = actions.close,
				["<Tab>"] = actions.move_selection_previous,
				["<S-Tab>"] = actions.move_selection_next,
				["<C-j>"] = actions.move_selection_next,
				["<C-k>"] = actions.move_selection_previous,
			},
		},
	},
	pickers = {
		extensions = {
			-- Configuration for the fzf extension
			fzf = {
				fuzzy = true, -- false for exact matching
				override_generic_sorter = true, -- override the generic sorter
				override_file_sorter = true, -- override the file sorter
				case_mode = "smart_case", -- or "ignore_case" or "respect_case"
			},
		},
	},
})

-- Load the fzf extension for Telescope
telescope.load_extension("fzf")

local builtin = require("telescope.builtin")
local utils = require("utils.utils") -- Load 'utils' module here

-- Custom key mappings for Telescope commands
utils.keymap("n", "tf", builtin.find_files, {
	desc = "Search for a file",
})
utils.keymap("n", "tg", builtin.live_grep, {
	desc = "Search for a string",
})
utils.keymap("n", "tw", builtin.grep_string, {
	desc = "Search for the string under your cursor or selection",
})
