local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	rocks = {
		enabled = false,
	},
	spec = {
		{
			"folke/which-key.nvim",
			event = "VeryLazy",
			opts = {
				icons = {
					mappings = false,
				},
			},
			keys = {
				{
					"<leader>?",
					function()
						require("which-key").show({
							global = false,
						})
					end,
					desc = "Help: Show local keymaps",
				},
			},
		},
		{
			"folke/todo-comments.nvim",
			event = "VeryLazy",
			dependencies = { "nvim-lua/plenary.nvim" },
		},
		{
			"nvim-neo-tree/neo-tree.nvim",
			branch = "v3.x",
			cmd = "Neotree",
			dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim" },
			config = function()
				require("neo-tree").setup({
					use_default_mappings = false,
					close_if_last_window = true,
					popup_border_style = "rounded",
					sources = { "filesystem", "document_symbols", "buffers" },
					source_selector = {
						sources = {
							{
								source = "filesystem",
							},
							{
								source = "document_symbols",
							},
							{
								source = "buffers",
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
						follow_current_file = {
							enabled = true,
						},
						filtered_items = {
							show_hidden_count = true,
							hide_dotfiles = true,
							hide_gitignored = true,
							hide_by_name = { "node_modules" },
							always_show = { ".gitignored" },
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
					document_symbols = {
						follow_cursor = true,
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
					event_handlers = {
						{
							event = "file_open_requested",
							handler = function()
								require("neo-tree.command").execute({
									action = "close",
								})
							end,
						},
						{
							event = "file_renamed",
							handler = function(args)
								print(args.source, " renamed to ", args.destination)
							end,
						},
						{
							event = "file_moved",
							handler = function(args)
								print(args.source, " moved to ", args.destination)
							end,
						},
					},
				})
			end,
		},
		{
			"ibhagwan/fzf-lua",
			event = "VeryLazy",
		},
		{
			"nvim-treesitter/nvim-treesitter",
			build = ":TSUpdate",
			config = function()
				local configs = require("nvim-treesitter.configs")
				configs.setup({
					auto_install = true,
					highlight = {
						enable = true,
					},
					indent = {
						enable = true,
					},
				})
			end,
		},
		{
			"stevearc/conform.nvim",
			event = "VeryLazy",
			config = function()
				require("conform").setup({
					format_on_save = function(bufnr)
						local bufname = vim.api.nvim_buf_get_name(bufnr)
						if bufname:match("/node_modules/") then
							return nil
						end
						return {
							timeout_ms = 1000,
							lsp_format = "fallback",
						}
					end,
				})
			end,
			init = function()
				vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
			end,
		},
		{
			"echasnovski/mini.statusline",
			version = "*",
			config = function()
				local statusline = require("mini.statusline")
				statusline.setup()

				statusline.section_location = function()
					return "%2l:%-2v"
				end
			end,
		},
		{
			"mason-org/mason.nvim",
			opts = {},
		},
		{
			"saghen/blink.cmp",
			version = "1.*",
			dependencies = "rafamadriz/friendly-snippets",
			opts = {
				keymap = {
					preset = "none",
					["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
					["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
					["<Up>"] = { "select_prev", "fallback" },
					["<Down>"] = { "select_next", "fallback" },
					["<CR>"] = { "accept", "fallback" },
				},
				completion = {
					documentation = {
						auto_show = true,
						auto_show_delay_ms = 500,
					},
					list = {
						selection = {
							preselect = false,
							auto_insert = true,
						},
					},
					accept = {
						auto_brackets = {
							enabled = true,
						},
					},
					ghost_text = {
						enabled = true,
					},
				},
				cmdline = {
					preset = "inherit",
					completion = {
						menu = {
							auto_show = function(ctx)
								return vim.fn.getcmdtype() == ":"
							end,
						},
						list = {
							selection = {
								preselect = false,
								auto_insert = true,
							},
						},
						ghost_text = {
							enabled = true,
						},
					},
				},
				sources = {
					providers = {
						buffer = {
							opts = {
								get_bufnrs = function()
									return vim.tbl_filter(function(bufnr)
										return vim.bo[bufnr].buftype == ""
									end, vim.api.nvim_list_bufs())
								end,
							},
						},
						cmdline = {
							min_keyword_length = function(ctx)
								if ctx.mode == "cmdline" and string.find(ctx.line, " ") == nil then
									return 3
								end
								return 0
							end,
						},
					},
				},
				signature = {
					enabled = true,
				},
			},
		},
		{
			"mfussenegger/nvim-dap",
			event = "VeryLazy",
			dependencies = {
				{
					"rcarriga/nvim-dap-ui",
					dependencies = { "nvim-neotest/nvim-nio" },
				},
				{ "theHamsta/nvim-dap-virtual-text" },
			},
			config = function()
				local dap = require("dap")
				local dapui = require("dapui")

				dapui.setup()

				dap.listeners.before.attach.dapui_config = function()
					dapui.open()
				end
				dap.listeners.before.launch.dapui_config = function()
					dapui.open()
				end
				dap.listeners.before.event_terminated.dapui_config = function()
					dapui.close()
				end
				dap.listeners.before.event_exited.dapui_config = function()
					dapui.close()
				end

				require("nvim-dap-virtual-text").setup()
			end,
		},
		{
			"leoluz/nvim-dap-go",
			ft = "go",
			config = function()
				require("dap-go").setup({})
			end,
		},
	},
})
