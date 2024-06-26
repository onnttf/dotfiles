-- [[ Set leader key ]]
-- Must be set before plugins are loaded to ensure the correct leader key is used
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- [[ Setting options ]]
-- Enable line numbers
vim.opt.number = true
-- Enable mouse mode for easier split resizing, etc.
vim.opt.mouse = "a"
-- Hide mode in command line (already displayed in status line)
vim.opt.showmode = false
-- Sync clipboard with OS clipboard
vim.opt.clipboard = "unnamedplus"
-- Enable break indent
vim.opt.breakindent = true
-- Save undo history
vim.opt.undofile = true
-- Case-insensitive searching unless using capital letters or \C
vim.opt.ignorecase = true
vim.opt.smartcase = true
-- Always show the sign column
vim.opt.signcolumn = "yes"
-- Reduce update time for better performance
vim.opt.updatetime = 250
-- Open new splits to the right and below by default
vim.opt.splitright = true
vim.opt.splitbelow = true
-- Show live preview of substitutions
-- vim.opt.inccommand = "split"
-- Highlight the current line
vim.opt.cursorline = true
-- Maintain a minimum of 10 lines above and below the cursor
vim.opt.scrolloff = 10
-- Enable smart indentation
vim.opt.smartindent = true
-- Enable automatic indentation
vim.opt.autoindent = true
-- Set tab size to 4 spaces
vim.opt.tabstop = 4
-- Set soft tab size to 4 spaces
vim.opt.softtabstop = 4
-- Set shift width to 4 spaces
vim.opt.shiftwidth = 4
-- Convert tabs to spaces
vim.opt.expandtab = true
-- Highlight search results
vim.opt.hlsearch = true

-- [[ Basic Keymaps ]]
-- Clear search highlights with <Esc> in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })
-- Diagnostic navigation keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
-- Disable arrow keys in normal mode to encourage hjkl usage
vim.keymap.set("n", "<left>", '<cmd>echo "Use h to move!"<CR>')
vim.keymap.set("n", "<right>", '<cmd>echo "Use l to move!"<CR>')
vim.keymap.set("n", "<up>", '<cmd>echo "Use k to move!"<CR>')
vim.keymap.set("n", "<down>", '<cmd>echo "Use j to move!"<CR>')
-- Easier window navigation with CTRL + hjkl
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to upper window" })

-- [[ Basic Autocommands ]]
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight yanked text",
	callback = function()
		vim.highlight.on_yank()
	end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
	desc = "Auto-create directories",
	callback = function(event)
		if event.match:match("^%w%w+:[\\/][\\/]") then
			return
		end
		local file = vim.uv.fs_realpath(event.match) or event.match
		vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	desc = "Close specific buffers with 'q'",
	pattern = { "help", "lspinfo" },
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = event.buf, silent = true })
	end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
	desc = "Return to last edit position",
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local lcount = vim.api.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

vim.api.nvim_create_autocmd("VimResized", {
	desc = "Equalize window sizes on resize",
	callback = function()
		vim.cmd("tabdo wincmd =")
	end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
-- See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
require("lazy").setup({
	checker = { enabled = true }, -- Automatically check for plugin updates
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
			opts = {},
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
			"lukas-reineke/indent-blankline.nvim",
			event = "VeryLazy",
			main = "ibl",
			opts = {},
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
				--  - yinq - [Y]ank [I]nside [N]ext [']quote
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
				{
					"j-hui/fidget.nvim",
					opts = {},
				},
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
			ft = { "go", "gomod" },
			dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
			config = function()
				require("plugin.lsp.gopher")
			end,
		},
	},
})
