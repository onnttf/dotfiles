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
		local function copy_path(state, modifier, label)
			local node = state.tree:get_node()
			local path = node.path or node:get_id()
			path = vim.fn.fnamemodify(path, modifier)
			vim.fn.setreg("+", path)
			vim.notify(("Copied %s: %s"):format(label, path))
		end

		require("neo-tree").setup({
			use_default_mappings = false,
			close_if_last_window = true,
			popup_border_style = "none",
			sources = { "filesystem", "document_symbols", "buffers" },
			source_selector = {
				sources = {
					{ source = "filesystem" },
					{ source = "document_symbols" },
					{ source = "buffers" },
				},
			},
			window = {
				position = "float",
				popup = { border = "none", title = "" },
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
				follow_current_file = { enabled = true },
				filtered_items = {
					hide_by_name = { "node_modules" },
					always_show = { ".gitignore" },
				},
				commands = {
					copy_path = function(state)
						copy_path(state, ":p", "path")
					end,
					copy_relative_path = function(state)
						copy_path(state, ":.", "relative path")
					end,
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
								state.commands.toggle_node(state)
							else
								state.commands.open(state)
								vim.cmd("Neotree reveal")
							end
						end,
						["a"] = { "add", config = { show_path = "relative" } },
						["d"] = "delete",
						["r"] = "rename",
						["c"] = { "copy", config = { show_path = "relative" } },
						["m"] = { "move", config = { show_path = "relative" } },
						["H"] = "toggle_hidden",
						["<bs>"] = "navigate_up",
						["."] = "set_root",
						["i"] = "show_file_details",
						["Y"] = "copy_path",
						["gy"] = "copy_relative_path",
					},
				},
			},
			document_symbols = { follow_cursor = true },
			buffers = {
				window = { mappings = { ["d"] = "buffer_delete" } },
			},
			event_handlers = {
				{
					event = "file_open_requested",
					handler = function()
						require("neo-tree.command").execute({ action = "close" })
					end,
				},
			},
		})
	end,
}
