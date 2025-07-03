-- [[ Plugin ]]
-- [[ Install `lazy.nvim` plugin manager ]]
-- Automatically sets up lazy.nvim if it's not already installed.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
-- Set up lazy.nvim and define all plugins.
require("lazy").setup({
	-- Lazy.nvim global options.
	rocks = {
		enabled = false,
	}, -- Disable Luarocks integration.
	spec = {
		{
			"folke/which-key.nvim",
			event = "VeryLazy", -- Load when Neovim is almost fully initialized.
			opts = {
				icons = {
					mappings = false,
				}, -- Disable icons for individual mappings.
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
			event = "VeryLazy", -- Load when Neovim is almost fully initialized.
			dependencies = { "nvim-lua/plenary.nvim" }, -- Required dependency.
		},
		{
			"nvim-neo-tree/neo-tree.nvim",
			branch = "v3.x", -- Specify the branch for v3.x.
			cmd = "Neotree", -- Load when Neotree command is called.
			dependencies = { -- Essential dependencies.
				"nvim-lua/plenary.nvim",
				"nvim-tree/nvim-web-devicons",
				"MunifTanjim/nui.nvim",
			},
			config = function()
				require("neo-tree").setup({
					use_default_mappings = false, -- Disable default mappings.
					close_if_last_window = true, -- Close Neo-tree if it's the last window.
					popup_border_style = "rounded", -- Use rounded borders for popups.
					sources = { "filesystem", "document_symbols", "buffers" }, -- Enabled sources.
					source_selector = {
						sources = { -- Configure source selector order.
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
						position = "float", -- Display as a floating window.
						mappings = { -- Custom window-level mappings.
							["<"] = "prev_source",
							[">"] = "next_source",
							["S"] = "open_split", -- Open in horizontal split.
							["s"] = "open_vsplit", -- Open in vertical split.
							["R"] = "refresh", -- Refresh current source.
							["<cr>"] = "open", -- Open selected node.
						},
					},
					filesystem = { -- Filesystem source configurations.
						follow_current_file = {
							enabled = true,
						}, -- Keep focused on current file.
						filtered_items = { -- Configure hidden/shown items.
							show_hidden_count = true,
							hide_dotfiles = true,
							hide_gitignored = true,
							hide_by_name = { "node_modules" },
							always_show = { ".gitignored" },
						},
						window = { -- Filesystem-specific window mappings.
							mappings = {
								["h"] = function(state) -- Navigate up or collapse directory.
									local node = state.tree:get_node()
									if node.type == "directory" and node:is_expanded() then
										require("neo-tree.sources.filesystem").toggle_directory(state, node)
									else
										require("neo-tree.ui.renderer").focus_node(state, node:get_parent_id())
									end
								end,
								["l"] = function(state) -- Expand directory or focus first child.
									local node = state.tree:get_node()
									if node.type == "directory" then
										if not node:is_expanded() then
											require("neo-tree.sources.filesystem").toggle_directory(state, node)
										elseif node:has_children() then
											require("neo-tree.ui.renderer").focus_node(state, node:get_child_ids()[1])
										end
									end
								end,
								["<tab>"] = function(state) -- Toggle node or open.
									local node = state.tree:get_node()
									if require("neo-tree.utils").is_expandable(node) then
										state.commands["toggle_node"](state)
									else
										state.commands["open"](state)
										vim.cmd("Neotree reveal") -- Reveal current file in tree.
									end
								end,
								["a"] = {
									"add",
									config = {
										show_path = "relative",
									},
								}, -- Add new item.
								["d"] = "delete", -- Delete item.
								["r"] = "rename", -- Rename item.
								["c"] = {
									"copy",
									config = {
										show_path = "relative",
									},
								}, -- Copy item.
								["m"] = {
									"move",
									config = {
										show_path = "relative",
									},
								}, -- Move item.
								["H"] = "toggle_hidden", -- Toggle hidden files visibility.
								["<bs>"] = "navigate_up", -- Navigate to parent.
								["."] = "set_root", -- Set current dir as root.
								["i"] = "show_file_details", -- Show file details.
							},
							fuzzy_finder_mappings = { -- Mappings for fuzzy finder.
								["<down>"] = "move_cursor_down",
								["<C-n>"] = "move_cursor_down",
								["<up>"] = "move_cursor_up",
								["<C-p>"] = "move_cursor_up",
							},
						},
					},
					document_symbols = {
						follow_cursor = true,
					}, -- Document symbols source config.
					buffers = { -- Buffers source configurations.
						follow_current_file = {
							enabled = true,
						},
						window = {
							mappings = {
								["d"] = "buffer_delete", -- Delete the buffer.
							},
						},
					},
					event_handlers = { -- Event handlers.
						{
							event = "file_open_requested",
							handler = function()
								require("neo-tree.command").execute({
									action = "close",
								}) -- Close Neo-tree after opening file.
							end,
						},
						{
							event = "file_renamed",
							handler = function(args)
								print(args.source, " renamed to ", args.destination) -- Log file rename.
							end,
						},
						{
							event = "file_moved",
							handler = function(args)
								print(args.source, " moved to ", args.destination) -- Log file move.
							end,
						},
					},
				})
			end,
		},
		{
			"MeanderingProgrammer/render-markdown.nvim",
			ft = { "markdown" }, -- Load only for markdown files.
			dependencies = { "nvim-treesitter/nvim-treesitter" }, -- Required dependency.
		},
		{
			"ibhagwan/fzf-lua",
			event = "VeryLazy", -- Load when Neovim is almost fully initialized.
		},
		{
			"nvim-treesitter/nvim-treesitter",
			build = ":TSUpdate", -- Command to run after installation/update.
			config = function()
				local configs = require("nvim-treesitter.configs")
				configs.setup({
					auto_install = true, -- Automatically install parsers.
					highlight = {
						enable = true,
					}, -- Enable Tree-sitter syntax highlighting.
					indent = {
						enable = true,
					}, -- Enable Tree-sitter indentation.
				})
			end,
		},
		{
			"stevearc/conform.nvim",
			event = "VeryLazy", -- Load when Neovim is almost fully initialized.
			config = function()
				require("conform").setup({
					formatters_by_ft = { -- Define formatters for each filetype.
						["*"] = { "codespell" },
						go = { "goimports", "gofumpt" },
						python = { "ruff" },
						javascript = { "prettierd" },
						jsx = { "prettierd" },
						typescript = { "prettierd" },
						html = { "prettierd" },
						css = { "prettierd" },
						lua = { "stylua" },
						bash = { "beautysh" },
						sh = { "beautysh" },
						json = { "prettierd" },
						markdown = { "markdownlint-cli2" },
						php = { "php-cs-fixer" },
						vue = { "prettierd" },
						yaml = { "prettierd" },
						sql = { "sql-formatter" },
						xml = { "xmlformatter" },
						shell = { "shfmt" },
					},
					format_on_save = function(bufnr) -- Custom logic for format on save.
						local bufname = vim.api.nvim_buf_get_name(bufnr)
						if bufname:match("/node_modules/") then
							return nil -- Disable autoformat for node_modules.
						end
						return {
							timeout_ms = 1000,
							lsp_format = "fallback", -- Fallback to LSP if conform fails.
						}
					end,
				})
			end,
			init = function()
				-- Set 'formatexpr' to use conform.nvim.
				vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
			end,
		},
		{
			"echasnovski/mini.ai",
			event = "VeryLazy", -- Text objects for "around in" selections.
			version = "*",
			opts = {},
		},
		{
			"echasnovski/mini.surround",
			event = "VeryLazy", -- Manage surrounding pairs.
			version = "*",
			opts = {},
		},
		{
			"echasnovski/mini.statusline",
			version = "*", -- Minimalist statusline.
			config = function()
				local statusline = require("mini.statusline")
				statusline.setup()
				-- Customize location section.
				statusline.section_location = function()
					return "%2l:%-2v"
				end
			end,
		},
		{
			"echasnovski/mini.pairs",
			event = "VeryLazy", -- Auto-pairs for brackets, quotes.
			version = "*",
			opts = {},
		},
		{
			"williamboman/mason.nvim",
			opts = {}, -- Use default Mason options.
		},
		{
			"saghen/blink.cmp",
			version = "1.*", -- Specify version constraint.
			dependencies = "rafamadriz/friendly-snippets", -- Snippet collection.
			opts = {
				keymap = {
					preset = "none",
					["<Tab>"] = { "select_next", "snippet_forward", "fallback" }, -- Next completion/snippet.
					["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" }, -- Previous completion/snippet.
					["<Up>"] = { "select_prev", "fallback" }, -- Up in completion list.
					["<Down>"] = { "select_next", "fallback" }, -- Down in completion list.
					["<CR>"] = { "accept", "fallback" }, -- Accept completion.
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
					ghost_text = {
						enabled = true,
					}, -- Enable ghost text.
				},
				cmdline = {
					preset = "inherit",
					completion = {
						menu = {
							auto_show = function(ctx)
								return vim.fn.getcmdtype() == ":" -- Show completion for command line.
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
									-- Get buffer numbers for normal file buffers.
									return vim.tbl_filter(function(bufnr)
										return vim.bo[bufnr].buftype == ""
									end, vim.api.nvim_list_bufs())
								end,
							},
						},
						cmdline = {
							min_keyword_length = function(ctx)
								-- Show command-line completion for keywords 3 chars or longer.
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
				}, -- Enable signature help.
			},
		},
		{
			"mfussenegger/nvim-dap",
			event = "VeryLazy", -- Load DAP when Neovim is almost fully initialized.
			dependencies = {
				{
					"rcarriga/nvim-dap-ui",
					dependencies = { "nvim-neotest/nvim-nio" },
				}, -- UI for DAP.
				{ "theHamsta/nvim-dap-virtual-text" }, -- Virtual text for debugger.
			},
			config = function()
				local dap = require("dap")
				local dapui = require("dapui")

				dapui.setup() -- Configure DAP UI.

				-- Automatically open/close DAP UI based on debug session events.
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

				require("nvim-dap-virtual-text").setup() -- Configure DAP virtual text.
			end,
		},
		{
			"leoluz/nvim-dap-go",
			ft = "go", -- Load only for Go files.
			config = function()
				require("dap-go").setup({}) -- Configure Go DAP extension.
			end,
		},
	},
})
