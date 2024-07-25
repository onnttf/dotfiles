local telescope = require("telescope")
local actions = require("telescope.actions")
local config = require("telescope.config")
local previewers = require("telescope.previewers")
local builtin = require("telescope.builtin")

-- List of file patterns to exclude from preview
local _bad = { ".*%.csv", ".*%.xlsx" }
local bad_files = function(filepath)
	for _, v in ipairs(_bad) do
		if filepath:match(v) then
			return false
		end
	end
	return true
end

-- Custom file previewer to exclude specific file types
local new_maker = function(filepath, bufnr, opts)
	opts = opts or {}
	if opts.use_ft_detect == nil then
		opts.use_ft_detect = true
	end
	opts.use_ft_detect = opts.use_ft_detect == false and false or bad_files(filepath)
	previewers.buffer_previewer_maker(filepath, bufnr, opts)
end

-- Customize vimgrep_arguments to include hidden files and exclude .git directory
local vimgrep_arguments = vim.tbl_deep_extend("force", {}, config.values.vimgrep_arguments or {})
table.insert(vimgrep_arguments, "--hidden")
table.insert(vimgrep_arguments, "--glob")
table.insert(vimgrep_arguments, "!**/.git/*")
-- table.insert(vimgrep_arguments, "--trim")

-- Configure Telescope with custom settings
telescope.setup({
	defaults = {
		-- Ignore files larger than 1 MB
		filesize_limit = 1, -- MB
		vimgrep_arguments = vimgrep_arguments,
		buffer_previewer_maker = new_maker,
		-- Key mappings for Telescope in insert and normal mode
		mappings = {
			i = { -- Insert mode mappings
				["<esc>"] = actions.close,
				["<C-u>"] = false, -- Clear the prompt instead of scrolling up
				["<C-j>"] = actions.move_selection_next, -- Move selection to next item
				["<C-k>"] = actions.move_selection_previous, -- Move selection to previous item
			},
			n = { -- Normal mode mappings
				["<esc>"] = actions.close, -- Close Telescope
				["<Tab>"] = actions.move_selection_previous, -- Move selection to previous item
				["<S-Tab>"] = actions.move_selection_next, -- Move selection to next item
				["<C-j>"] = actions.move_selection_next, -- Move selection to next item
				["<C-k>"] = actions.move_selection_previous, -- Move selection to previous item
			},
		},
	},
	pickers = {
		find_files = {
			-- Include hidden files but exclude .git directory
			-- find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
		},
	},
	extensions = {
		fzf = { -- FZF extension settings
			fuzzy = true, -- Enable fuzzy searching
			override_generic_sorter = true, -- Override generic sorter
			override_file_sorter = true, -- Override file sorter
			case_mode = "smart_case", -- Smart case mode
		},
	},
})

-- Load FZF extension if installed
pcall(telescope.load_extension, "fzf")

-- Key mappings for common Telescope functions
vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
vim.keymap.set("n", "<leader>sr", builtin.oldfiles, { desc = "[S]earch [R]ecent Files" })
vim.keymap.set("n", "<leader>sb", builtin.buffers, { desc = "[S]earch [B]uffers" })
vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch [W]ord" })
vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
vim.keymap.set("n", "<leader>s.", function()
	builtin.find_files({ cwd = vim.fn.expand("%:p:h") })
end, { desc = "[S]earch Sibling Files" })
