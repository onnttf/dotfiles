local telescope = require("telescope")
local actions = require("telescope.actions")
local config = require("telescope.config")
local previewers = require("telescope.previewers")
local builtin = require("telescope.builtin")

-- List of file patterns to exclude from preview
local _bad = { ".*%.csv", ".*%.xlsx" }
local function bad_files(filepath)
	for _, pattern in ipairs(_bad) do
		if filepath:match(pattern) then
			return false
		end
	end
	return true
end

-- Custom file previewer to exclude specific file types
local function new_maker(filepath, bufnr, opts)
	opts = opts or {}
	opts.use_ft_detect = opts.use_ft_detect ~= false and bad_files(filepath)
	previewers.buffer_previewer_maker(filepath, bufnr, opts)
end

-- Customize vimgrep_arguments to include hidden files and exclude .git directory
local vimgrep_arguments = vim.tbl_deep_extend("force", {}, config.values.vimgrep_arguments or {})
table.insert(vimgrep_arguments, "--hidden")
table.insert(vimgrep_arguments, "--glob")
table.insert(vimgrep_arguments, "!**/.git/*")

-- Configure Telescope with custom settings
telescope.setup({
	defaults = {
		filesize_limit = 1, -- Ignore files larger than 1 MB
		vimgrep_arguments = vimgrep_arguments,
		buffer_previewer_maker = new_maker,
		mappings = {
			i = { -- Insert mode mappings
				["<esc>"] = actions.close,
				["<C-u>"] = false, -- Clear prompt instead of scrolling
				["<C-j>"] = actions.move_selection_next,
				["<C-k>"] = actions.move_selection_previous,
			},
			n = { -- Normal mode mappings
				["<esc>"] = actions.close,
				["<Tab>"] = actions.move_selection_previous,
				["<S-Tab>"] = actions.move_selection_next,
				["<C-j>"] = actions.move_selection_next,
				["<C-k>"] = actions.move_selection_previous,
			},
		},
	},
	pickers = {
		find_files = {
			-- Uncomment to use ripgrep for file finding
			-- find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
		},
	},
	extensions = {
		fzf = {
			fuzzy = true,
			override_generic_sorter = true,
			override_file_sorter = true,
			case_mode = "smart_case",
		},
	},
})

-- Load FZF extension if installed
pcall(telescope.load_extension, "fzf")

-- Key mappings for common Telescope functions
local function map(mode, lhs, rhs, opts)
	opts = opts or {}
	opts.silent = opts.silent ~= false
	vim.keymap.set(mode, lhs, rhs, opts)
end

map("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
map("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
map("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
map("n", "<leader>sr", builtin.oldfiles, { desc = "[S]earch [R]ecent Files" })
map("n", "<leader>sb", builtin.buffers, { desc = "[S]earch [B]uffers" })
map("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch [W]ord" })
map("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
map("n", "<leader>s.", function()
	builtin.find_files({ cwd = vim.fn.expand("%:p:h") })
end, { desc = "[S]earch Sibling Files" })
