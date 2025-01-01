-- [[ Core Configuration ]]
-- Set leader key (must be set before plugins are loaded)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- [[ Essential Options ]]
-- Define a table of options for easy management
local options = {
	number = true, -- Show line numbers
	mouse = "a", -- Enable mouse support in all modes
	showmode = false, -- Don't show mode in command line (shown in statusline)
	breakindent = true, -- Enable break indent for wrapped lines
	ignorecase = true, -- Case insensitive searching
	smartcase = true, -- Case sensitive if search contains capitals
	signcolumn = "yes", -- Always show the sign column (for diagnostics, etc.)
	updatetime = 250, -- Decrease update time for better performance
	timeoutlen = 300, -- Decrease timeout for mapped key sequences
	splitright = true, -- Open vertical splits to the right
	splitbelow = true, -- Open horizontal splits below
	cursorline = true, -- Highlight the current line
	scrolloff = 10, -- Keep 10 lines above/below the cursor
	hlsearch = true, -- Highlight search results
	termguicolors = true, -- Enable true color support in terminal
	smartindent = true, -- Enable smart indentation
	autoindent = true, -- Enable automatic indentation
	tabstop = 4, -- Set tab size to 4 spaces
	softtabstop = 4, -- Set soft tab size to 4 spaces
	shiftwidth = 4, -- Set shift width to 4 spaces
	expandtab = true, -- Convert tabs to spaces
	backup = false, -- Disable backup files
	swapfile = false, -- Disable swap files
	undofile = false, -- Disable undo files
}

-- Apply all options
for k, v in pairs(options) do
	vim.opt[k] = v
end

-- Sync clipboard between OS and Neovim
-- Schedule the setting after `UiEnter` because it can increase startup-time
vim.schedule(function()
	vim.opt.clipboard = "unnamedplus"
end)

-- [[ Basic Keymaps ]]
-- Define default options
local default_opts = { noremap = true, silent = true }

-- Create a function that merges default_opts with any additional options
local function keymap(mode, lhs, rhs, opts)
	opts = opts or {}
	opts = vim.tbl_extend("force", default_opts, opts)
	vim.keymap.set(mode, lhs, rhs, opts)
end

-- Clear search highlights
keymap("n", "<Esc>", "<cmd>nohlsearch<CR><cmd>let @/ = ''<CR>", { desc = "Clear highlights and search content" })

-- Window navigation with CTRL + hjkl
keymap("n", "<C-h>", "<C-w>h", { desc = "Focus left window" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Focus bottom window" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Focus top window" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Focus right window" })

-- Remap for dealing with word wrap
keymap("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
keymap("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Use black hole register (_) to void the deleted text in visual mode
keymap("v", "p", '"_d"+p', { desc = "Paste from clipboard" })

-- [[ Autocommands ]]
local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

local autocmd = vim.api.nvim_create_autocmd

-- Highlight on yank
autocmd("TextYankPost", {
	group = augroup,
	desc = "Highlight yanked text",
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Auto-create directories when saving a file
autocmd("BufWritePre", {
	group = augroup,
	desc = "Create parent directories on save",
	callback = function(event)
		if event.match:match("^%w%w+:[\\/][\\/]") then
			return
		end
		local file = vim.uv.fs_realpath(event.match) or event.match
		vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
	end,
})

-- Close specific buffers with 'q' and manage Quickfix behaviors
autocmd("FileType", {
	group = augroup,
	desc = "Use 'q' to close specific buffers and manage Quickfix",
	pattern = { "help", "lspinfo", "neo-tree", "qf" },
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = event.buf, silent = true })
		if event.match == "qf" then
			vim.api.nvim_buf_set_keymap(event.buf, "n", "<CR>", "<CR>:cclose<CR>", { noremap = true, silent = true })
		end
	end,
})

-- Return to last edit position
autocmd("BufReadPost", {
	group = augroup,
	desc = "Go to last location when reopening a file",
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local lcount = vim.api.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- Equalize window sizes on resize
autocmd("VimResized", {
	group = augroup,
	desc = "Auto-resize splits on window resize",
	callback = function()
		vim.cmd("tabdo wincmd =")
	end,
})

-- [[ Plugin Manager Setup ]]
-- Install and set up `lazy.nvim` plugin manager
-- See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
require("lazy").setup({
	checker = { enabled = false }, -- Automatically check for plugin updates
	rocks = { enabled = false }, -- Disable LuaRocks integration
	spec = {
		-- NOTE: Plugins can also be added by using a table,
		-- with the first argument being the link and the following
		-- keys can be used to configure plugin behavior/loading/etc.
		--
		-- Use `opts = {}` to force a plugin to be loaded.
		{
			"folke/which-key.nvim",
			event = "VeryLazy",
			opts = {
				-- your configuration comes here
				-- or leave it empty to use the default settings
				-- refer to the configuration section below
				icons = {
					mappings = false,
				},
			},
			keys = {
				{
					"<leader>",
					function()
						require("which-key").show({ global = false })
					end,
					desc = "Buffer Local Keymaps (which-key)",
				},
			},
		},
		{
			"folke/todo-comments.nvim",
			dependencies = { "nvim-lua/plenary.nvim" },
			opts = {},
		},
		{
			"MeanderingProgrammer/render-markdown.nvim",
			ft = { "markdown" },
			dependencies = { "nvim-treesitter/nvim-treesitter" },
			opts = {},
		},
		{
			"nvim-neo-tree/neo-tree.nvim",
			event = "VeryLazy",
			branch = "v3.x",
			dependencies = {
				"nvim-lua/plenary.nvim",
				"nvim-tree/nvim-web-devicons",
				"MunifTanjim/nui.nvim",
			},
			opts = {
				use_default_mappings = false,
				close_if_last_window = true,
				sources = { "filesystem", "document_symbols" },
				use_popups_for_input = false,
				source_selector = {
					sources = {
						{ source = "filesystem" },
						{ source = "document_symbols" },
					},
				},
				window = {
					position = "float",
					mappings = {
						["<cr>"] = "open",
						["<"] = "prev_source",
						[">"] = "next_source",
					},
				},
				filesystem = {
					filtered_items = {
						show_hidden_count = true,
						hide_dotfiles = true,
						hide_gitignored = true,
						hide_by_name = {
							"node_modules",
						},
						always_show = {
							".gitignored",
						},
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
							["d"] = "delete",
							["r"] = "rename",
							["H"] = "toggle_hidden",
							-- ["/"] = "fuzzy_finder",
							["."] = "set_root",
							["<bs>"] = "navigate_up",
							["i"] = "show_file_details",
						},
						-- fuzzy_finder_mappings = {
						-- 	["<down>"] = "move_cursor_down",
						-- 	["<C-n>"] = "move_cursor_down",
						-- 	["<up>"] = "move_cursor_up",
						-- 	["<C-p>"] = "move_cursor_up",
						-- },
					},
				},
				document_symbols = {
					follow_cursor = true,
				},
			},
			--config = function()
			--	require("plugin.neo-tree")
			--end,
		},
		{
			"lewis6991/gitsigns.nvim",
			event = "VeryLazy",
			opts = {},
		},

		--{
		--	"nvim-telescope/telescope.nvim",
		--	event = "VeryLazy",
		--	dependencies = {
		--		"nvim-lua/plenary.nvim",
		--	},
		--	opts = {},
		--},
		{
			"ibhagwan/fzf-lua",
			dependencies = { "nvim-tree/nvim-web-devicons" },
			event = "VeryLazy",
			opts = {},
		},
		{
			"nvimdev/dashboard-nvim",
			event = "VimEnter",
			config = function()
				require("dashboard").setup({
					theme = "hyper",
					change_to_vcs_root = true,
					config = {
						shortcut = {
							{
								desc = "New file",
								action = "enew",
								key = "e",
							},
							--{
							--	desc = "Files",
							--	action = "Telescope find_files cwd=.",
							--	key = "f",
							--},
							{
								desc = "Config",
								action = "tabnew $MYVIMRC | tcd %:p:h",
								key = "c",
							},
						},
						header = {
							"                                                       ",
							" ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗",
							" ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║",
							" ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║",
							" ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║",
							" ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║",
							" ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝",
							"                                                       ",
						},
						footer = {
							"",
							"😀 Meet a better version of yourself every day.",
						},
					},
				})
			end,
			dependencies = { "nvim-tree/nvim-web-devicons" },
		},
		{
			"lukas-reineke/indent-blankline.nvim",
			event = "VeryLazy",
			main = "ibl",
			opts = {
				exclude = {
					filetypes = { "dashboard" },
				},
			},
		},
		{
			"nvim-treesitter/nvim-treesitter",
			dependencies = {
				"nvim-treesitter/nvim-treesitter-textobjects",
			},
			event = "VeryLazy",
			build = ":TSUpdate",
			config = function()
				require("plugin.nvim-treesitter")
			end,
		},
		{
			"folke/trouble.nvim",
			dependencies = {
				"nvim-tree/nvim-web-devicons",
			},
			event = "VeryLazy",
			opts = {},
		},
		{
			"stevearc/conform.nvim",
			event = { "BufWritePre" },
			cmd = { "ConformInfo" },
			init = function()
				-- If you want the formatexpr, here is the place to set it
				vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
			end,
			config = function()
				require("plugin.conform")
			end,
		},
		{
			"echasnovski/mini.nvim",
			event = "VeryLazy",
			config = function()
				-- Better Around/Inside textobjects
				--
				-- Examples:
				--  - va)  - [V]isually select [A]round [)]paren
				--  - yinq - [Y]ank [I]nside [N]ext [Q]uote
				--  - ci'  - [C]hange [I]nside [']quote
				require("mini.ai").setup({
					n_lines = 500,
				})

				-- Add/delete/replace surroundings (brackets, quotes, etc.)
				--
				-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
				-- - sd'   - [S]urround [D]elete [']quotes
				-- - sr)'  - [S]urround [R]eplace [)] [']
				require("mini.surround").setup()

				-- Simple and easy statusline.
				--  You could remove this setup call if you don't like it,
				--  and try some other statusline plugin
				local statusline = require("mini.statusline")
				statusline.setup()
				statusline.section_location = function()
					return "%2l:%-2v"
				end

				require("mini.pairs").setup()

				require("mini.diff").setup()
				-- ... and there is more!
				--  Check out: https://github.com/echasnovski/mini.nvim
			end,
		},
		{
			"neovim/nvim-lspconfig",
			dependencies = {
				"williamboman/mason.nvim",
				"williamboman/mason-lspconfig.nvim",
				"WhoIsSethDaniel/mason-tool-installer.nvim",
			},
			config = function()
				require("plugin.lsp.nvim-lspconfig")
				-- Add keymaps when an LSP is attached to the current buffer
				vim.api.nvim_create_autocmd("LspAttach", {
					group = augroup,
					callback = function(ev)
						-- Enable completion triggered by <c-x><c-o>
						vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

						-- Buffer local mappings
						local localOpts = { buffer = ev.buf }

						-- Movement related (g)
						keymap(
							"n",
							"gd",
							vim.lsp.buf.definition,
							vim.tbl_extend("force", localOpts, { desc = "Go to definition" })
						)
						keymap(
							"n",
							"gD",
							vim.lsp.buf.declaration,
							vim.tbl_extend("force", localOpts, { desc = "Go to definition" })
						)
						keymap(
							"n",
							"gr",
							vim.lsp.buf.references,
							vim.tbl_extend("force", localOpts, { desc = "Go to declaration" })
						)
						keymap(
							"n",
							"gi",
							vim.lsp.buf.implementation,
							vim.tbl_extend("force", localOpts, { desc = "Go to implementation" })
						)
						keymap(
							"n",
							"gt",
							vim.lsp.buf.type_definition,
							vim.tbl_extend("force", localOpts, { desc = "Go to type definition" })
						)

						-- Hover and signature help
						keymap(
							"n",
							"K",
							vim.lsp.buf.hover,
							vim.tbl_extend("force", localOpts, { desc = "Show hover information" })
						)
						keymap(
							"n",
							"<C-k>",
							vim.lsp.buf.signature_help,
							vim.tbl_extend("force", localOpts, { desc = "Show signature help" })
						)

						-- Edit related (e)
						keymap(
							"n",
							"er",
							vim.lsp.buf.rename,
							vim.tbl_extend("force", localOpts, { desc = "Rename symbol" })
						)
						keymap(
							{ "n", "v" },
							"ea",
							vim.lsp.buf.code_action,
							vim.tbl_extend("force", localOpts, { desc = "Code actions" })
						)
					end,
				})
			end,
		},
		{
			"saghen/blink.cmp",
			lazy = false, -- lazy loading handled internally
			-- optional: provides snippets for the snippet source
			dependencies = "rafamadriz/friendly-snippets",
			-- use a release tag to download pre-built binaries
			version = "v0.*",
			opts = {
				-- 'default' for mappings similar to built-in completion
				-- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
				-- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
				-- see the "default configuration" section below for full documentation on how to define
				-- your own keymap.
				keymap = {
					["<CR>"] = { "accept", "fallback" },

					["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
					["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },

					["<Up>"] = { "select_prev", "fallback" },
					["<Down>"] = { "select_next", "fallback" },

					["<C-b>"] = { "scroll_documentation_up", "fallback" },
					["<C-f>"] = { "scroll_documentation_down", "fallback" },
				},
				completion = {
					-- Don't select by default, auto insert on selection
					list = { selection = { preselect = false, auto_insert = false } },
					-- Show documentation when selecting a completion item
					documentation = { auto_show = true, auto_show_delay_ms = 500 },
					-- Display a preview of the selected item on the current line
					ghost_text = { enabled = true },
				},
				sources = {
					-- Remove 'buffer' if you don't want text completions, by default it's only enabled when LSP returns no items
					default = { "lsp", "path", "snippets", "buffer" },
					-- Disable cmdline completions
					cmdline = {},
				},
				-- Experimental signature help support
				signature = { enabled = true },
			},
		},
	},
})
