local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- Install lazy.nvim if not already installed
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system(
		-- Latest stable release
		{ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath }
	)
end

-- Add lazy.nvim to runtime path
vim.opt.rtp:prepend(lazypath)

-- Load LSP configuration
local lsp = require("plugins/lsp/init")

-- Define a list of plugins
local plugins = {
	{
		"projekt0n/github-nvim-theme",
		lazy = false, -- Load during startup if it is the main colorscheme
		priority = 1000, -- Load before all other start plugins
		config = function()
			-- Load the colorscheme here
			require("plugins/github-nvim-theme")
		end,
	},
	-- {
	-- 	"glepnir/dashboard-nvim",
	-- 	dependencies = { "nvim-tree/nvim-web-devicons" },
	-- 	event = "VimEnter",
	-- 	config = function()
	-- 		require("plugins/dashboard-nvim")
	-- 	end,
	-- },
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim" },
		event = "VeryLazy",
		config = function()
			require("plugins/neo-tree")
		end,
	},
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
			},
		},
		event = "VeryLazy",
		config = function()
			require("plugins/telescope")
		end,
	},
	-- {
	-- 	"lewis6991/gitsigns.nvim",
	-- 	cmd = "Gitsigns",
	-- 	config = function()
	-- 		require("plugins/gitsigns")
	-- 	end,
	-- },
	{
		"nvim-treesitter/nvim-treesitter",
		-- event = "VeryLazy",
		build = ":TSUpdate",
		config = function()
			require("plugins/nvim-treesitter")
		end,
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		event = "VeryLazy",
		config = function()
			require("plugins.indent-blankline")
		end,
	},
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		cmd = "Trouble",
		config = function()
			require("plugins.trouble")
		end,
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
	},
	{
		"nvimtools/none-ls.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		event = "VeryLazy",
		config = function()
			require("plugins.none-ls")
		end,
	},
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = { "markdown" },
		build = function()
			vim.fn["mkdp#util#install"]()
		end,
	},
	lsp,
}

-- Setup lazy-loading for the defined plugins
require("lazy").setup(plugins)
