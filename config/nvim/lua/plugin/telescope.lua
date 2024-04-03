local actions = require("telescope.actions")
local telescope = require("telescope")

-- Set up telescope with default settings
telescope.setup({
	defaults = {
		-- Define key mappings for insert and normal mode
		mappings = {
			i = { -- Insert mode mappings
				["<C-u>"] = false, -- Disable scrolling up
				["<Tab>"] = actions.move_selection_previous, -- Move selection to previous item
				["<S-Tab>"] = actions.move_selection_next, -- Move selection to next item
				["<C-j>"] = actions.move_selection_next, -- Move selection to next item
				["<C-k>"] = actions.move_selection_previous, -- Move selection to previous item
			},
			n = { -- Normal mode mappings
				["<esc>"] = actions.close, -- Close telescope
				["<Tab>"] = actions.move_selection_previous, -- Move selection to previous item
				["<S-Tab>"] = actions.move_selection_next, -- Move selection to next item
				["<C-j>"] = actions.move_selection_next, -- Move selection to next item
				["<C-k>"] = actions.move_selection_previous, -- Move selection to previous item
			},
		},
	},
	pickers = {}, -- Define pickers
	extensions = {
		["ui-select"] = { require("telescope.themes").get_dropdown() }, -- UI theme for dropdown
		fzf = { -- Settings for fzf extension
			fuzzy = true, -- Enable fuzzy searching
			override_generic_sorter = true, -- Override generic sorter
			override_file_sorter = true, -- Override file sorter
			case_mode = "smart_case", -- Set case mode to smart case
		},
	},
})

-- Load extensions
telescope.load_extension("fzf")
telescope.load_extension("ui-select")

local builtin = require("telescope.builtin")
local util = require("util")

-- Define key mappings for various telescope commands
util.keymap("n", "<leader>sh", builtin.help_tags, {
	desc = "[S]earch [H]elp", -- Description for the key mapping
})
util.keymap("n", "<leader>sk", builtin.keymaps, {
	desc = "[S]earch [K]eymaps",
})
util.keymap("n", "<leader>sf", builtin.find_files, {
	desc = "[S]earch [F]iles",
})
util.keymap("n", "<leader>ss", builtin.builtin, {
	desc = "[S]earch [S]elect Telescope",
})
util.keymap("n", "<leader>sw", builtin.grep_string, {
	desc = "[S]earch current [W]ord",
})
util.keymap("n", "<leader>sg", builtin.live_grep, {
	desc = "[S]earch by [G]rep",
})
util.keymap("n", "<leader>sd", builtin.diagnostics, {
	desc = "[S]earch [D]iagnostics",
})
util.keymap("n", "<leader>sr", builtin.resume, {
	desc = "[S]earch [R]esume",
})
util.keymap("n", "<leader>s.", builtin.oldfiles, {
	desc = '[S]earch Recent Files ("." for repeat)',
})
util.keymap("n", "<leader><leader>", builtin.buffers, {
	desc = "[ ] Find existing buffers",
})

-- Define key mapping for current buffer fuzzy search
util.keymap("n", "<leader>/", function()
	builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
		winblend = 10,
		previewer = false,
	}))
end, {
	desc = "[/] Fuzzily search in current buffer",
})

-- Define key mapping for live grep in open files
util.keymap("n", "<leader>s/", function()
	builtin.live_grep({
		grep_open_files = true,
		prompt_title = "Live Grep in Open Files",
	})
end, {
	desc = "[S]earch [/] in Open Files",
})

-- Define key mapping for searching Neovim configuration files
util.keymap("n", "<leader>sn", function()
	builtin.find_files({
		cwd = vim.fn.stdpath("config"),
	})
end, {
	desc = "[S]earch [N]eovim files",
})

return M
