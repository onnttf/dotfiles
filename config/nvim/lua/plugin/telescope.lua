local telescope = require("telescope")
local actions = require("telescope.actions")

local previewers = require("telescope.previewers")
local Job = require("plenary.job")
local new_maker = function(filepath, bufnr, opts)
	filepath = vim.fn.expand(filepath)
	Job:new({
		command = "file",
		args = { "--mime-type", "-b", filepath },
		on_exit = function(j)
			local mime_type = vim.split(j:result()[1], "/")[1]
			if mime_type == "text" then
				previewers.buffer_previewer_maker(filepath, bufnr, opts)
			else
				-- maybe we want to write something to the buffer here
				vim.schedule(function()
					vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "BINARY" })
				end)
			end
		end,
	}):sync()
end

-- Set up telescope with default settings
telescope.setup({
	defaults = {
		buffer_previewer_maker = new_maker,
		-- Define key mappings for insert and normal mode
		mappings = {
			i = { -- Insert mode mappings
				["<esc>"] = actions.close,
				["<C-u>"] = false, -- Disable scrolling up
				-- ["<Tab>"] = actions.move_selection_previous, -- Move selection to previous item
				-- ["<S-Tab>"] = actions.move_selection_next, -- Move selection to next item
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
	pickers = {
		find_files = {
			mappings = {
				n = {
					["."] = function(prompt_bufnr)
						local selection = require("telescope.actions.state").get_selected_entry()
						local dir = vim.fn.fnamemodify(selection.path, ":p:h")
						require("telescope.actions").close(prompt_bufnr)
						-- Depending on what you want put `cd`, `lcd`, `tcd`
						vim.cmd(string.format("silent lcd %s", dir))
					end,
				},
			},
		},
	},
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

-- Enable Telescope extensions if they are installed
pcall(telescope.load_extension, "fzf")
pcall(telescope.load_extension, "ui-select")

-- See `:help telescope.builtin`
local builtin = require("telescope.builtin")

vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

-- Slightly advanced example of overriding default behavior and theme
vim.keymap.set("n", "<leader>/", function()
	-- You can pass additional configuration to Telescope to change the theme, layout, etc.
	builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
		winblend = 10,
		previewer = false,
	}))
end, { desc = "[/] Fuzzily search in current buffer" })

-- It's also possible to pass additional configuration options.
--  See `:help telescope.builtin.live_grep()` for information about particular keys
vim.keymap.set("n", "<leader>s/", function()
	builtin.live_grep({
		grep_open_files = true,
		prompt_title = "Live Grep in Open Files",
	})
end, { desc = "[S]earch [/] in Open Files" })

-- Shortcut for searching your Neovim configuration files
vim.keymap.set("n", "<leader>sn", function()
	builtin.find_files({ cwd = vim.fn.stdpath("config") })
end, { desc = "[S]earch [N]eovim files" })
