local actions = require("telescope.actions")

-- Configure Telescope with custom settings
require("telescope").setup({
	--defaults = {
	--	mappings = {
	--		i = { -- Insert mode mappings
	--			["<esc>"] = actions.close,
	--			["<C-u>"] = false, -- Clear prompt instead of scrolling
	--			["<C-j>"] = actions.move_selection_next,
	--			["<C-k>"] = actions.move_selection_previous,
	--		},
	--		n = { -- Normal mode mappings
	--			["<esc>"] = actions.close,
	--			["<Tab>"] = actions.move_selection_previous,
	--			["<S-Tab>"] = actions.move_selection_next,
	--			["<C-j>"] = actions.move_selection_next,
	--			["<C-k>"] = actions.move_selection_previous,
	--		},
	--	},
	--},
})

-- Key mappings for common Telescope functions
--local function map(mode, lhs, rhs, opts)
--	opts = opts or {}
--	opts.silent = opts.silent ~= false
--	vim.keymap.set(mode, lhs, rhs, opts)
--end
--
--map("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
--map("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
--map("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
--map("n", "<leader>sr", builtin.oldfiles, { desc = "[S]earch [R]ecent Files" })
--map("n", "<leader>sb", builtin.buffers, { desc = "[S]earch [B]uffers" })
--map("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch [W]ord" })
--map("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
--map("n", "<leader>s.", function()
--	builtin.find_files({ cwd = vim.fn.expand("%:p:h") })
--end, { desc = "[S]earch Sibling Files" })
