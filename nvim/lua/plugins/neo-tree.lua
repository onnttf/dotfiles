-- https://github.com/nvim-neo-tree/neo-tree.nvim
return {
	"nvim-neo-tree/neo-tree.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	cmd = "Neotree",
	config = function()
		require("neo-tree").setup({
			use_default_mappings = false,
			close_if_last_window = true,
			popup_border_style   = "rounded",
			sources              = { "filesystem", "document_symbols", "buffers" },
			source_selector      = {
				sources = {
					{ source = "filesystem" },
					{ source = "document_symbols" },
					{ source = "buffers" },
				},
			},
			window = {
				position = "float",
				mappings = {
					["<"]    = "prev_source",
					[">"]    = "next_source",
					["S"]    = "open_split",
					["s"]    = "open_vsplit",
					["R"]    = "refresh",
					["<cr>"] = "open",
				},
			},
			filesystem = {
				follow_current_file = { enabled = true },
				filtered_items      = {
					show_hidden_count = true,
					hide_dotfiles     = true,
					hide_gitignored   = true,
					hide_by_name      = { "node_modules" },
					always_show       = { ".gitignore" },
				},
				window = {
					mappings = {
						-- Collapse directory or navigate to parent.
						["h"] = function(state)
							local node = state.tree:get_node()
							if node.type == "directory" and node:is_expanded() then
								require("neo-tree.sources.filesystem").toggle_directory(state, node)
							else
								require("neo-tree.ui.renderer").focus_node(state, node:get_parent_id())
							end
						end,
						-- Expand directory or enter first child.
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
						-- Toggle node or open file and reveal in tree.
						["<tab>"] = function(state)
							local node = state.tree:get_node()
							if require("neo-tree.utils").is_expandable(node) then
								state.commands["toggle_node"](state)
							else
								state.commands["open"](state)
								vim.cmd("Neotree reveal")
							end
						end,
						["a"]    = { "add",    config = { show_path = "relative" } },
						["d"]    = "delete",
						["r"]    = "rename",
						["c"]    = { "copy",   config = { show_path = "relative" } },
						["m"]    = { "move",   config = { show_path = "relative" } },
						["H"]    = "toggle_hidden",
						["<bs>"] = "navigate_up",
						["."]    = "set_root",
						["i"]    = "show_file_details",
					},
					fuzzy_finder_mappings = {
						["<down>"]  = "move_cursor_down",
						["<C-n>"]   = "move_cursor_down",
						["<up>"]    = "move_cursor_up",
						["<C-p>"]   = "move_cursor_up",
					},
				},
			},
			document_symbols = { follow_cursor = true },
			buffers          = {
				follow_current_file = { enabled = true },
				window = { mappings = { ["d"] = "buffer_delete" } },
			},
			event_handlers = {
				-- Close Neo-tree when a file is opened.
				{
					event = "file_open_requested",
					handler = function() require("neo-tree.command").execute({ action = "close" }) end,
				},
				-- Print rename/move notifications.
				{
					event = "file_renamed",
					handler = function(args) print(args.source, " renamed to ", args.destination) end,
				},
				{
					event = "file_moved",
					handler = function(args) print(args.source, " moved to ", args.destination) end,
				},
			},
		})
	end,
}
