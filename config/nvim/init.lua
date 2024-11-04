-- [[ Core Configuration ]]
-- Set leader key (must be set before plugins are loaded)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- [[ Essential Options ]]
-- Define a table of options for easy management
local options = {
	number = true, -- Show line numbers
	mouse = "a", -- Enable mouse for all modes
	showmode = false, -- Don't show mode in command line (shown in statusline)
	breakindent = true, -- Enable break indent
	ignorecase = true, -- Case insensitive searching
	smartcase = true, -- Case sensitive if search contains capitals
	signcolumn = "yes", -- Always show the sign column
	updatetime = 250, -- Decrease update time for better performance
	timeoutlen = 300, -- Decrease mapped sequence wait time
	splitright = true, -- Open new vertical splits to the right
	splitbelow = true, -- Open new horizontal splits below
	cursorline = true, -- Highlight the current line
	scrolloff = 10, -- Maintain 10 lines above/below cursor
	smartindent = true, -- Enable smart indentation
	autoindent = true, -- Enable automatic indentation
	tabstop = 4, -- Set tab size to 4 spaces
	softtabstop = 4, -- Set soft tab size to 4 spaces
	shiftwidth = 4, -- Set shift width to 4 spaces
	expandtab = true, -- Convert tabs to spaces
	hlsearch = true, -- Highlight search results
	termguicolors = true, -- Enable 24-bit RGB color in the TUI
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

-- Now use this function for all your keymaps

-- Clear search highlights
keymap("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear highlights" })

-- Diagnostic navigation
keymap("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
keymap("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })

-- Disable arrow keys in normal mode (encourage hjkl usage)
for _, key in ipairs({ "left", "right", "up", "down" }) do
	keymap("n", "<" .. key .. ">", string.format('<cmd>echo "Use %s to move!"<CR>', key:sub(1, 1)))
end

-- Window navigation with CTRL + hjkl
for _, key in ipairs({ "h", "j", "k", "l" }) do
	keymap("n", "<C-" .. key .. ">", "<C-w><C-" .. key .. ">", { desc = "Focus " .. key .. " window" })
end

-- Remap for dealing with word wrap
keymap("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
keymap("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- [[ Autocommands ]]
local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup,
	desc = "Highlight yanked text",
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Auto-create directories when saving a file
vim.api.nvim_create_autocmd("BufWritePre", {
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

-- Close specific buffers with 'q'
vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	desc = "Use 'q' to close specific buffers",
	pattern = { "help", "lspinfo", "neo-tree" },
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		keymap("n", "q", "<cmd>close<CR>", { buffer = event.buf, silent = true })
	end,
})

-- Return to last edit position
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

-- Equalize window sizes on resize
vim.api.nvim_create_autocmd("VimResized", {
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
		},
		{
			"folke/todo-comments.nvim",
			dependencies = { "nvim-lua/plenary.nvim" },
			opts = {
				-- your configuration comes here
				-- or leave it empty to use the default settings
				-- refer to the configuration section below
			},
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
			init = function()
				-- If you want the formatexpr, here is the place to set it
				vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
			end,
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
		--{
		--	"lewis6991/gitsigns.nvim",
		--	event = "VeryLazy",
		--	opts = {},
		--},
		-- {
		--     "olexsmir/gopher.nvim",
		--     ft = "go",
		--     -- branch = "develop", -- if you want develop branch
		--     -- keep in mind, it might break everything
		--     dependencies = {
		--         "nvim-lua/plenary.nvim",
		--         "nvim-treesitter/nvim-treesitter",
		--         --   "mfussenegger/nvim-dap", -- (optional) only if you use `gopher.dap`
		--     },
		--     -- (optional) will update plugin's deps on every update
		--     build = function()
		--         vim.cmd.GoInstallDeps()
		--     end,
		--     opts = {},
		-- },
	},
})
