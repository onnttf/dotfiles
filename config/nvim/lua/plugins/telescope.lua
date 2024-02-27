-- https://github.com/nvim-telescope/telescope.nvim

-- Load required Telescope modules
local actions = require("telescope.actions")
local telescope = require("telescope")

-- Configure Telescope defaults and pickers
telescope.setup({
	defaults = {
		mappings = {
			i = {
				["<C-u>"] = false, -- Disable preview on <C-u>
				["<Tab>"] = actions.move_selection_previous, -- Move selection to previous item
				["<S-Tab>"] = actions.move_selection_next, -- Move selection to next item
				["<C-j>"] = actions.move_selection_next, -- Move selection to next item
				["<C-k>"] = actions.move_selection_previous, -- Move selection to previous item
			},
			n = {
				["<esc>"] = actions.close, -- Close Telescope on <esc>
				["<Tab>"] = actions.move_selection_previous, -- Move selection to previous item
				["<S-Tab>"] = actions.move_selection_next, -- Move selection to next item
				["<C-j>"] = actions.move_selection_next, -- Move selection to next item
				["<C-k>"] = actions.move_selection_previous, -- Move selection to previous item
			},
		},
	},
	pickers = {
		extensions = {
			-- Configuration for the fzf extension
			fzf = {
				fuzzy = true, -- Enable fuzzy searching
				override_generic_sorter = true, -- Override the generic sorter
				override_file_sorter = true, -- Override the file sorter
				case_mode = "smart_case", -- Use smart case sensitivity
			},
		},
	},
})

-- Load the fzf extension for Telescope
telescope.load_extension("fzf")

-- Load required Telescope modules
local builtin = require("telescope.builtin")
local utils = require("utils.utils") -- Load 'utils' module here

-- Custom key mappings for Telescope commands
utils.keymap("n", "sf", builtin.find_files, {
	desc = "[S]earch [F]iles", -- Description for find_files command
})
utils.keymap("n", "sg", builtin.live_grep, {
	desc = "[S]earch by [G]rep", -- Description for live_grep command
})
utils.keymap("n", "sw", builtin.grep_string, {
	desc = "[S]earch current [W]ord", -- Description for grep_string command
})
