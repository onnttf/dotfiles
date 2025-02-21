local neotree = require("neo-tree")
local renderer = require("neo-tree.ui.renderer")

neotree.setup({
	use_default_mappings = false,
	close_if_last_window = true,
	sources = { "filesystem", "buffers", "git_status", "document_symbols" },
	use_popups_for_input = false,
	source_selector = {
		sources = {
			{
				source = "filesystem",
			},
			{
				source = "buffers",
			},
			{
				source = "git_status",
			},
			{
				source = "document_symbols",
			},
		},
	},
	window = {
		position = "float",
		mappings = {
			["<"] = "prev_source",
			[">"] = "next_source",
			["S"] = "open_split",
			["s"] = "open_vsplit",
			["R"] = "refresh",
			["<cr>"] = "open",
		},
	},
	filesystem = {
		filtered_items = {
			show_hidden_count = true,
			hide_dotfiles = true,
			hide_gitignored = true,
			hide_by_name = { "node_modules" },
			always_show = { ".gitignored" },
		},
		follow_current_file = {
			enabled = true,
		},
		window = {
			mappings = {
				["h"] = function(state)
					local node = state.tree:get_node()
					if node.type == "directory" and node:is_expanded() then
						require("neo-tree.sources.filesystem").toggle_directory(state, node)
					else
						require("neo-tree.ui.renderer").focus_node(state, node:get_parent_id())
					end
				end,
				["l"] = function(state)
					local node = state.tree:get_node()
					if node.type == "directory" then
						if not node:is_expanded() then
							require("neo-tree.sources.filesystem").toggle_directory(state, node)
						elseif node:has_children() then
							require("neo-tree.ui.renderer").focus_node(state, node:get_child_ids()[1])
						end
					end
				end,
				["<tab>"] = function(state)
					local node = state.tree:get_node()
					if require("neo-tree.utils").is_expandable(node) then
						state.commands["toggle_node"](state)
					else
						state.commands["open"](state)
						vim.cmd("Neotree reveal")
					end
				end,
				["a"] = {
					"add",
					config = {
						show_path = "relative",
					},
				},
				["d"] = "delete",
				["r"] = "rename",
				["c"] = {
					"copy",
					config = {
						show_path = "relative",
					},
				},
				["m"] = {
					"move",
					config = {
						show_path = "relative",
					},
				},
				["H"] = "toggle_hidden",
				["<bs>"] = "navigate_up",
				["."] = "set_root",
				["i"] = "show_file_details",
			},
			fuzzy_finder_mappings = {
				["<down>"] = "move_cursor_down",
				["<C-n>"] = "move_cursor_down",
				["<up>"] = "move_cursor_up",
				["<C-p>"] = "move_cursor_up",
			},
		},
	},
	buffers = {
		follow_current_file = {
			enabled = true,
		},
		window = {
			mappings = {
				["d"] = "buffer_delete",
			},
		},
	},
	git_status = {
		window = {
			mappings = {
				["A"] = "git_add_all",
				["gu"] = "git_unstage_file",
				["ga"] = "git_add_file",
				["gr"] = "git_revert_file",
				["gc"] = "git_commit",
				["gp"] = "git_push",
				["gg"] = "git_commit_and_push",
			},
		},
	},
	document_symbols = {
		follow_cursor = true,
	},
	event_handlers = {
		{
			event = "neo_tree_window_after_open",
			handler = function(args)
				if args.position == "left" or args.position == "right" then
					vim.cmd("wincmd =")
				end
			end,
		},
		{
			event = "neo_tree_window_after_close",
			handler = function(args)
				if args.position == "left" or args.position == "right" then
					vim.cmd("wincmd =")
				end
			end,
		},
	},
})
