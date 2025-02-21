-- [[ Core Configuration ]]
-- Set the global leader key.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- [[ Essential Options ]]
-- Manage Neovim options using a table for easy reference.
local options = {
	number = true, -- Enable line numbers.
	mouse = "a", -- Enable mouse support in all modes.
	showmode = false, -- Disable mode display (already shown in the status line).
	breakindent = true, -- Enable break indent.
	ignorecase = true, -- Case-insensitive searching unless \C or capital letters are used.
	smartcase = true, -- Smart case sensitivity.
	signcolumn = "yes", -- Always show the sign column.
	updatetime = 250, -- Decrease update time for better performance.
	timeoutlen = 300, -- Decrease the wait time for mapped sequences.
	splitright = true, -- Open new vertical splits to the right.
	splitbelow = true, -- Open new horizontal splits below.
	list = true, -- Display certain whitespace characters.
	listchars = {
		tab = "» ", -- Display tabs as "» ".
		trail = "·", -- Display trailing spaces as "·".
		nbsp = "␣", -- Display non-breaking spaces as "␣".
	},
	cursorline = true, -- Highlight the line with the cursor.
	scrolloff = 10, -- Keep at least 10 lines above/below the cursor.
	undofile = true, -- Save undo history to a file.
}

-- Apply options from the table.
for k, v in pairs(options) do
	vim.opt[k] = v
end

-- Sync clipboard with OS, run after UI setup to reduce startup time.
vim.schedule(function()
	vim.opt.clipboard = "unnamedplus"
end)

-- [[ Basic Keymaps ]]
-- Define default keymap options.
local default_opts = {
	noremap = true, -- Disable recursive mapping.
	silent = true, -- Suppress command output.
}

-- Helper function to merge default options with additional options.
local function keymap(mode, lhs, rhs, opts)
	opts = opts or {}
	opts = vim.tbl_extend("force", default_opts, opts)
	vim.keymap.set(mode, lhs, rhs, opts)
end

-- Clear search highlights and reset the search register.
keymap("n", "<Esc>", "<cmd>nohlsearch<CR><cmd>let @/ = ''<CR>", {
	desc = "Clear search highlights and reset search register",
})

-- Use CTRL+<hjkl> to switch between windows.
keymap("n", "<C-h>", "<C-w>h", {
	desc = "Move focus to the left window",
})
keymap("n", "<C-j>", "<C-w>j", {
	desc = "Move focus to the lower window",
})
keymap("n", "<C-k>", "<C-w>k", {
	desc = "Move focus to the upper window",
})
keymap("n", "<C-l>", "<C-w>l", {
	desc = "Move focus to the right window",
})

-- Remap for handling word wrap with `k` and `j`.
keymap("n", "k", "v:count == 0 ? 'gk' : 'k'", {
	expr = true,
	silent = true,
})
keymap("n", "j", "v:count == 0 ? 'gj' : 'j'", {
	expr = true,
	silent = true,
})

-- Use the black hole register to avoid overwriting the default register when pasting.
keymap("v", "p", '"_d"+p', {
	desc = "Paste from clipboard without overwriting the default register",
})

-- [[ Autocommands ]]
-- Create an augroup for user-defined autocommands.
local augroup = vim.api.nvim_create_augroup("UserConfig", {
	clear = true,
})

-- Highlight yanked text.
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup,
	desc = "Highlight yanked text",
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Auto-create directories when saving a file.
vim.api.nvim_create_autocmd("BufWritePre", {
	group = augroup,
	desc = "Auto-create directories when saving a file",
	callback = function(event)
		if event.match:match("^%w%w+:[\\/][\\/]") then
			return
		end
		local file = vim.uv.fs_realpath(event.match) or event.match
		vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
	end,
})

-- Close specific buffers with 'q'.
vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	desc = "Use 'q' to close specific buffers",
	pattern = { "help", "lspinfo", "neo-tree", "qf" },
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<CR>", {
			buffer = event.buf,
			silent = true,
		})
		if event.match == "qf" then
			vim.api.nvim_buf_set_keymap(event.buf, "n", "<CR>", "<CR>:cclose<CR>", {
				noremap = true,
				silent = true,
			})
		end
	end,
})

-- Return to the last edit position when reopening a file.
vim.api.nvim_create_autocmd("BufReadPost", {
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

-- Resize splits automatically when Vim window is resized.
vim.api.nvim_create_autocmd("VimResized", {
	group = augroup,
	desc = "Auto-resize splits on window resize",
	callback = function()
		vim.cmd("tabdo wincmd =")
	end,
})

-- [[ Plugin Manager Setup ]]
-- Install and set up `lazy.nvim` plugin manager.
-- See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and Install Plugins ]]
require("lazy").setup({
	checker = {
		enabled = false, -- Disable automatic plugin updates.
	},
	rocks = {
		enabled = false, -- Disable LuaRocks integration.
	},
	spec = { -- Plugins can be added as strings or tables with additional configuration.
		-- Use `opts = {}` to force a plugin to load with default settings.
		-- Automatically detect tabstop and shiftwidth.
		"tpope/vim-sleuth",
		{
			"folke/which-key.nvim",
			event = "VeryLazy", -- Load on first use.
			opts = {
				icons = {
					mappings = false, -- Disable icons in keybindings.
				},
			},
			keys = {
				{
					"<leader>",
					function()
						require("which-key").show({
							global = false,
						})
					end,
					desc = "Buffer Local Keymaps (which-key)",
				},
			},
		},
		{
			"folke/todo-comments.nvim",
			event = "VeryLazy",
			dependencies = { "nvim-lua/plenary.nvim" },
			opts = {}, -- Use default settings.
		},
		{
			"MeanderingProgrammer/render-markdown.nvim",
			ft = { "markdown" }, -- Load only for Markdown files.
			dependencies = { "nvim-treesitter/nvim-treesitter" },
			opts = {}, -- Use default settings.
		},
		{
			"nvim-neo-tree/neo-tree.nvim",
			event = "VeryLazy",
			branch = "v3.x",
			dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim" },
			opts = {
				use_default_mappings = false, -- Disable default mappings.
				close_if_last_window = true, -- Close Neo-Tree if it's the last window.
				sources = { "filesystem", "document_symbols" }, -- Enable filesystem and symbols sources.
				use_popups_for_input = false, -- Disable popups for input.
				source_selector = {
					sources = {
						{
							source = "filesystem",
						},
						{
							source = "document_symbols",
						},
					},
				},
				window = {
					position = "float", -- Open Neo-Tree in a floating window.
					mappings = {
						["<cr>"] = "open", -- Open selected file or directory.
						["<"] = "prev_source", -- Switch to previous source.
						[">"] = "next_source", -- Switch to next source.
					},
				},
				filesystem = {
					filtered_items = {
						show_hidden_count = true, -- Show count of hidden items.
						hide_dotfiles = true, -- Hide dotfiles by default.
						hide_gitignored = true, -- Hide gitignored files.
						hide_by_name = { "node_modules" }, -- Hide specific directories.
						always_show = { ".gitignore" }, -- Always show specific files.
					},
					follow_current_file = {
						enabled = true,
					}, -- Follow the current file.
				},
				document_symbols = {
					follow_cursor = true, -- Follow the cursor in the symbols view.
				},
			},
		},
		{
			"lewis6991/gitsigns.nvim",
			event = "VeryLazy",
			opts = {}, -- Use default settings.
		},
		{
			"ibhagwan/fzf-lua",
			dependencies = { "nvim-tree/nvim-web-devicons" },
			event = "VeryLazy",
			opts = {}, -- Use default settings.
		},
		{
			"nvimdev/dashboard-nvim",
			event = "VimEnter", -- Load on Neovim startup.
			config = function()
				require("dashboard").setup({
					theme = "hyper",
					change_to_vcs_root = true, -- Change to VCS root directory.
					config = {
						shortcut = {
							{
								desc = "New file",
								action = "enew",
								key = "e",
							},
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
						footer = { "", "😀 Meet a better version of yourself every day." },
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
				}, -- Exclude specific filetypes.
			},
		},
		{
			"nvim-treesitter/nvim-treesitter",
			dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
			event = "VeryLazy",
			build = ":TSUpdate", -- Update parsers on install.
			config = function()
				require("plugin.nvim-treesitter") -- Load custom Treesitter configuration.
			end,
		},
		{
			"folke/trouble.nvim",
			dependencies = { "nvim-tree/nvim-web-devicons" },
			event = "VeryLazy",
			opts = {}, -- Use default settings.
		},
		{
			"stevearc/conform.nvim",
			event = { "BufWritePre" }, -- Run before saving a buffer.
			cmd = { "ConformInfo" },
			keys = {
				{
					"<leader>f",
					function()
						require("conform").format({
							async = true,
							lsp_format = "fallback",
						})
					end,
					mode = "",
					desc = "[F]ormat buffer",
				},
			},
			init = function()
				vim.o.formatexpr = "v:lua.require'conform'.formatexpr()" -- Set formatexpr.
			end,
			config = function()
				require("plugin.conform") -- Load custom Conform configuration.
			end,
		},
		{
			"echasnovski/mini.nvim",
			event = "VeryLazy",
			config = function()
				-- Better text objects for around/inside operations.
				require("mini.ai").setup({
					n_lines = 500,
				})

				-- Surround text with brackets, quotes, etc.
				require("mini.surround").setup()

				-- Simple statusline.
				local statusline = require("mini.statusline")
				statusline.setup()
				statusline.section_location = function()
					return "%2l:%-2v" -- Show line and column numbers.
				end

				-- Auto-pair brackets, quotes, etc.
				require("mini.pairs").setup()

				-- Diff viewer for better Git integration.
				require("mini.diff").setup()
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
				require("plugin.lsp.nvim-lspconfig") -- Load custom LSP configuration.
				vim.api.nvim_create_autocmd("LspAttach", {
					group = augroup,
					callback = function(ev)
						-- Enable completion triggered by <c-x><c-o>.
						vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

						-- Buffer-local keymaps for LSP functionality.
						local localOpts = {
							buffer = ev.buf,
						}
						keymap(
							"n",
							"gd",
							vim.lsp.buf.definition,
							vim.tbl_extend("force", localOpts, {
								desc = "Go to definition",
							})
						)
						keymap(
							"n",
							"gD",
							vim.lsp.buf.declaration,
							vim.tbl_extend("force", localOpts, {
								desc = "Go to declaration",
							})
						)
						keymap(
							"n",
							"gr",
							vim.lsp.buf.references,
							vim.tbl_extend("force", localOpts, {
								desc = "Go to references",
							})
						)
						keymap(
							"n",
							"gi",
							vim.lsp.buf.implementation,
							vim.tbl_extend("force", localOpts, {
								desc = "Go to implementation",
							})
						)
						keymap(
							"n",
							"gt",
							vim.lsp.buf.type_definition,
							vim.tbl_extend("force", localOpts, {
								desc = "Go to type definition",
							})
						)
						keymap(
							"n",
							"K",
							vim.lsp.buf.hover,
							vim.tbl_extend("force", localOpts, {
								desc = "Show hover information",
							})
						)
						keymap(
							"n",
							"<C-k>",
							vim.lsp.buf.signature_help,
							vim.tbl_extend("force", localOpts, {
								desc = "Show signature help",
							})
						)
						keymap(
							"n",
							"er",
							vim.lsp.buf.rename,
							vim.tbl_extend("force", localOpts, {
								desc = "Rename symbol",
							})
						)
						keymap(
							{ "n", "v" },
							"ea",
							vim.lsp.buf.code_action,
							vim.tbl_extend("force", localOpts, {
								desc = "Code actions",
							})
						)
					end,
				})
			end,
		},
		{
			"saghen/blink.cmp",
			lazy = false, -- Load immediately.
			dependencies = "rafamadriz/friendly-snippets",
			version = "v0.*",
			opts = {
				keymap = {
					["<CR>"] = { "accept", "fallback" },
					["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
					["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
					["<Up>"] = { "select_prev", "fallback" },
					["<Down>"] = { "select_next", "fallback" },
					["<C-b>"] = { "scroll_documentation_up", "fallback" },
					["<C-f>"] = { "scroll_documentation_down", "fallback" },
				},
				-- Disable cmdline
				cmdline = {
					enabled = false,
				},
				completion = {
					-- Disable auto brackets
					accept = { auto_brackets = { enabled = false } },
					-- Don't select by default, auto insert on selection
					list = { selection = { preselect = false, auto_insert = true } },
					-- Show documentation when selecting a completion item
					documentation = { auto_show = true, auto_show_delay_ms = 500 },
					-- Display a preview of the selected item on the current line
					ghost_text = { enabled = true },
				},
				sources = {
					-- Remove 'buffer' if you don't want text completions, by default it's only enabled when LSP returns no items
					default = { "lsp", "path", "snippets", "buffer" },
				},
				-- Experimental signature help support
				signature = { enabled = true },
			},
		},
		{
			"mfussenegger/nvim-dap",
			event = "VeryLazy",
			dependencies = {
				{
					"rcarriga/nvim-dap-ui",
					dependencies = { "nvim-neotest/nvim-nio" },
					opts = {},
				},
				{
					"theHamsta/nvim-dap-virtual-text",
					opts = {},
				},
			},
			config = function()
				local dap, dapui = require("dap"), require("dapui")
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
			end,
		},
		{
			"leoluz/nvim-dap-go",
			ft = "go",
			config = function()
				require("dap-go").setup({
					delve = {
						path = "/Users/zhangpeng/go/bin/dlv",
					},
				})
			end,
		},
	},
})
