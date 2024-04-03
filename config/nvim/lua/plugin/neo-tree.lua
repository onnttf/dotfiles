local function getTelescopeOpts(state, path)
	return {
		cwd = path, -- Current working directory for telescope
		search_dirs = { path }, -- Directories to search in
		attach_mappings = function(prompt_bufnr, map)
			local actions = require("telescope.actions")
			actions.select_default:replace(function()
				actions.close(prompt_bufnr) -- Close telescope prompt buffer
				local action_state = require("telescope.actions.state")
				local selection = action_state.get_selected_entry() -- Get selected entry
				local filename = selection.filename -- Get filename from selection
				if filename == nil then
					filename = selection[1] -- Use first item if filename is nil
				end

				require("neo-tree.sources.filesystem").navigate(state, state.path, filename) -- Navigate to selected file in neotree
			end)
			return true
		end,
	}
end

require("neo-tree").setup({
	sources = { "filesystem", "buffers", "git_status", "document_symbols" }, -- Define sources for neotree
	source_selector = {
		sources = {
			{
				source = "filesystem", -- Filesystem source
			},
			{
				source = "buffers", -- Buffers source
			},
			{
				source = "git_status", -- Git status source
			},
			{
				source = "document_symbols", -- Document symbols source
			},
		},
	},
	use_default_mappings = false, -- Disable default neotree mappings
	close_if_last_window = true, -- Close neotree if last window is closed

	open_files_do_not_replace_types = { "terminal", "trouble", "qf" }, -- Do not replace these types of buffers when opening files
	window = {
		mappings = {
			["<"] = "prev_source", -- Go to previous source
			[">"] = "next_source", -- Go to next source
			["<esc>"] = "close_window", -- Close neotree window on escape
			["q"] = "close_window", -- Close neotree window on q
			["S"] = "open_split", -- Open neotree in split
			["s"] = "open_vsplit", -- Open neotree in vsplit
			["<cr>"] = "open", -- Open selected file or directory
			["z"] = "close_all_nodes", -- Close all neotree nodes
			["R"] = "refresh", -- Refresh neotree
		},
	},
	filesystem = {
		hijack_netrw_behavior = "open_default", -- Use default behavior for netrw
		filtered_items = {
			hide_by_name = { "node_modules" }, -- Hide node_modules directory
			always_show = { ".gitignore" }, -- Always show .gitignore file
		},
		follow_current_file = {
			enabled = true, -- Enable following current file
			leave_dirs_open = false, -- Do not leave directories open
		},
		use_libuv_file_watcher = true, -- Use libuv file watcher
		window = {
			mappings = {

				["h"] = function(state) -- Go to parent directory or collapse current directory
					local node = state.tree:get_node()
					if node.type == "directory" and node:is_expanded() then
						require("neo-tree.sources.filesystem").toggle_directory(state, node)
					else
						require("neo-tree.ui.renderer").focus_node(state, node:get_parent_id())
					end
				end,
				["l"] = function(state) -- Expand or focus on child directory
					local node = state.tree:get_node()
					if node.type == "directory" then
						if not node:is_expanded() then
							require("neo-tree.sources.filesystem").toggle_directory(state, node)
						elseif node:has_children() then
							require("neo-tree.ui.renderer").focus_node(state, node:get_child_ids()[1])
						end
					end
				end,
				["<tab>"] = function(state) -- Toggle node or open file in new buffer
					local node = state.tree:get_node()
					if require("neo-tree.utils").is_expandable(node) then
						state.commands["toggle_node"](state)
					else
						state.commands["open"](state)
						vim.cmd("Neotree reveal")
					end
				end,
				["tf"] = "telescope_find", -- Use telescope to find files
				["tg"] = "telescope_grep", -- Use telescope to grep
				["a"] = { -- Add file to git
					"add",
					config = {
						show_path = "relative",
					},
				},
				["d"] = "delete", -- Delete file or directory
				["r"] = "rename", -- Rename file or directory
				["c"] = { -- Copy file or directory
					"copy",
					config = {
						show_path = "relative",
					},
				},
				["m"] = { -- Move file or directory
					"move",
					config = {
						show_path = "relative",
					},
				},
				["y"] = "copy_to_clipboard", -- Copy file path to clipboard
				["x"] = "cut_to_clipboard", -- Cut file path to clipboard
				["p"] = "paste_from_clipboard", -- Paste file path from clipboard
				["H"] = "toggle_hidden", -- Toggle showing hidden files
				["/"] = "fuzzy_finder", -- Use fuzzy finder to search files
				["<C-/>"] = "fuzzy_finder_directory", -- Use fuzzy finder to search directories
				["<bs>"] = "navigate_up", -- Navigate up in directory structure
				["."] = "set_root", -- Set current directory as root
			},
			fuzzy_finder_mappings = {
				["<down>"] = "move_cursor_down", -- Move cursor down in fuzzy finder
				["<C-n>"] = "move_cursor_down", -- Move cursor down in fuzzy finder
				["<up>"] = "move_cursor_up", -- Move cursor up in fuzzy finder
				["<C-p>"] = "move_cursor_up", -- Move cursor up in fuzzy finder
			},
		},
		commands = {
			telescope_find = function(state) -- Use telescope to find files
				local node = state.tree:get_node()
				local path = node:get_id()
				require("telescope.builtin").find_files(getTelescopeOpts(state, path))
			end,
			telescope_grep = function(state) -- Use telescope to grep
				local node = state.tree:get_node()
				local path = node:get_id()
				require("telescope.builtin").live_grep(getTelescopeOpts(state, path))
			end,
		},
	},
	buffers = {
		follow_current_file = {
			enabled = true, -- Enable following current file
			leave_dirs_open = false, -- Do not leave directories open
		},
		window = {
			mappings = {
				["d"] = "buffer_delete", -- Delete buffer
			},
		},
	},
	git_status = {
		window = {
			mappings = {
				["a"] = "git_add_file", -- Stage file
				["A"] = "git_add_all", -- Stage all files
				["u"] = "git_unstage_file", -- Unstage file
				["r"] = "git_revert_file", -- Revert file
				["c"] = "git_commit", -- Commit changes
				["p"] = "git_push", -- Push changes
				["cp"] = "git_commit_and_push", -- Commit and push changes
			},
		},
	},
	event_handlers = {
		{
			event = "neo_tree_window_after_open",
			handler = function(args) -- Handle window after open event
				if args.position == "left" or args.position == "right" then
					vim.cmd("wincmd =") -- Balance windows
				end
			end,
		},
		{
			event = "neo_tree_window_after_close",
			handler = function(args) -- Handle window after close event
				if args.position == "left" or args.position == "right" then
					vim.cmd("wincmd =") -- Balance windows
				end
			end,
		},
	},
	-- }, {
	--     event = "file_opened",
	--     handler = function(file_path)
	--         require("neo-tree.command").execute({
	--             action = "close"
	--         })
	--     end
	-- }}
})
