-- [[ Core Configuration ]]
-- Set leader key (must be set before plugins are loaded)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- [[ Essential Options ]]
vim.opt.number = true -- Show line numbers
vim.opt.mouse = "a" -- Enable mouse for all modes
vim.opt.showmode = false -- Don't show mode in command line (shown in statusline)
vim.opt.clipboard = "unnamedplus" -- Sync with system clipboard
vim.opt.breakindent = true -- Enable break indent
vim.opt.undofile = true -- Save undo history
vim.opt.ignorecase = true -- Case insensitive searching
vim.opt.smartcase = true -- Case sensitive if search contains capitals
vim.opt.signcolumn = "yes" -- Always show the sign column
vim.opt.updatetime = 250 -- Decrease update time for better performance
vim.opt.timeoutlen = 300 -- Decrease mapped sequence wait time

-- [[ Split Behavior ]]
vim.opt.splitright = true -- Open new vertical splits to the right
vim.opt.splitbelow = true -- Open new horizontal splits below

-- [[ Appearance ]]
vim.opt.cursorline = true -- Highlight the current line
vim.opt.scrolloff = 10 -- Maintain 10 lines above/below cursor

-- [[ Indentation ]]
vim.opt.smartindent = true -- Enable smart indentation
vim.opt.autoindent = true -- Enable automatic indentation
vim.opt.tabstop = 4 -- Set tab size to 4 spaces
vim.opt.softtabstop = 4 -- Set soft tab size to 4 spaces
vim.opt.shiftwidth = 4 -- Set shift width to 4 spaces
vim.opt.expandtab = true -- Convert tabs to spaces

-- [[ Search ]]
vim.opt.hlsearch = true -- Highlight search results

-- [[ Basic Keymaps ]]
-- Clear search highlights
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear highlights" })

-- Diagnostic navigation
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })

-- Disable arrow keys in normal mode (encourage hjkl usage)
vim.keymap.set("n", "<left>", '<cmd>echo "Use h to move!"<CR>')
vim.keymap.set("n", "<right>", '<cmd>echo "Use l to move!"<CR>')
vim.keymap.set("n", "<up>", '<cmd>echo "Use k to move!"<CR>')
vim.keymap.set("n", "<down>", '<cmd>echo "Use j to move!"<CR>')

-- Window navigation with CTRL + hjkl
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Focus left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Focus right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Focus lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Focus upper window" })

-- Remap for dealing with word wrap
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- [[ Autocommands ]]
-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight yanked text",
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Auto-create directories when saving a file
vim.api.nvim_create_autocmd("BufWritePre", {
	desc = "Create parent directories on save",
	callback = function(event)
		if event.match:match("^%w%w+:[\\/][\\/]") then
			return
		end
		local file = vim.uv.fs_realpath(event.match) or event.match
		vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
	end,
})

-- Close specific buffers with 'q'
vim.api.nvim_create_autocmd("FileType", {
	desc = "Use 'q' to close specific buffers",
	pattern = { "help", "lspinfo", "neo-tree" },
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = event.buf, silent = true })
	end,
})

-- Return to last edit position
vim.api.nvim_create_autocmd("BufReadPost", {
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
vim.api.nvim_create_autocmd("VimResized", {
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
		--
		--{
		--	"projekt0n/github-nvim-theme",
		--	priority = 1000, -- Make sure to load this before all the other start plugins.
		--	config = function()
		--		require("github-theme").setup({
		--			options = {
		--				-- Enable transparent background
		--				transparent = true,
		--			},
		--		})
		--		vim.cmd.colorscheme("github_dark")
		--	end,
		--},
		{
			"folke/which-key.nvim",
			event = "VeryLazy",
			opts = {
				icons = {
					rules = false,
				},
			},
			init = function()
				-- Decrease mapped sequence wait time
				-- Displays which-key popup sooner
				vim.opt.timeoutlen = 300
			end,
		},
		{
			"nvim-neo-tree/neo-tree.nvim",
			event = "VeryLazy",
			branch = "v3.x",
			dependencies = {
				"nvim-lua/plenary.nvim",
				{
					"nvim-tree/nvim-web-devicons",
				},
				"MunifTanjim/nui.nvim",
			},
			config = function()
				require("plugin.neo-tree")
			end,
		},
		{
			"nvim-telescope/telescope.nvim",
			event = "VeryLazy",
			dependencies = {
				"nvim-lua/plenary.nvim",
				{
					"nvim-telescope/telescope-fzf-native.nvim",
					build = "make",
					cond = function()
						return vim.fn.executable("make") == 1
					end,
				},
				{ "nvim-telescope/telescope-ui-select.nvim" },
				{
					"nvim-tree/nvim-web-devicons",
				},
			},
			config = function()
				require("plugin.telescope")
			end,
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
							{
								desc = "Files",
								action = "Telescope find_files cwd=.",
								key = "f",
							},
							{
								desc = "Config",
								action = "tabnew $MYVIMRC | tcd %:p:h",
								key = "c",
							},
							-- {
							-- 	desc = "Update",
							-- 	action = "Lazy update",
							-- 	key = "u",
							-- },
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
			dependencies = { { "nvim-tree/nvim-web-devicons" } },
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
			cmd = "Trouble",
			opts = {
				mode = "document_diagnostics",
			},
		},
		{
			"stevearc/conform.nvim",
			event = { "BufWritePre" },
			cmd = { "ConformInfo" },
			config = function()
				require("plugin.conform")
			end,
		},
		{
			"akinsho/toggleterm.nvim",
			version = "*",
			event = "VeryLazy",
			opts = { {
				direction = "float",
				open_mapping = [[<c-\>]],
			} },
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

				require("mini.comment").setup()

				require("mini.git").setup()

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
				-- {
				-- 	"j-hui/fidget.nvim",
				-- 	opts = {},
				-- },
			},
			config = function()
				require("plugin.lsp.nvim-lspconfig")
			end,
		},
		{
			"hrsh7th/nvim-cmp",
			event = "VeryLazy",
			dependencies = {
				"hrsh7th/cmp-nvim-lsp",
				"hrsh7th/cmp-buffer",
				"hrsh7th/cmp-path",
				"hrsh7th/cmp-cmdline",
				{
					"hrsh7th/cmp-vsnip",
					dependencies = { "hrsh7th/vim-vsnip", "rafamadriz/friendly-snippets" },
				},
			},
			config = function()
				require("plugin.lsp.nvim-cmp")
			end,
		},
		{
			"olexsmir/gopher.nvim",
			ft = "go",
			-- branch = "develop", -- if you want develop branch
			-- keep in mind, it might break everything
			dependencies = {
				"nvim-lua/plenary.nvim",
				"nvim-treesitter/nvim-treesitter",
				--   "mfussenegger/nvim-dap", -- (optional) only if you use `gopher.dap`
			},
			-- (optional) will update plugin's deps on every update
			build = function()
				vim.cmd.GoInstallDeps()
			end,
			opts = {},
		},
	},
})
