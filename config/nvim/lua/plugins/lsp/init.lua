-- LSP configuration

local lsp_config = {
	{
	  "neovim/nvim-lspconfig",
	  dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		{
		  "hrsh7th/nvim-cmp",
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
			require("plugins.lsp.nvim-cmp")
		  end,
		},
	  },
	  config = function()
		require("plugins.lsp.nvim-lspconfig")
	  end,
	},
	{
	  "olexsmir/gopher.nvim",
	  dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	  },
	  config = function()
		require("plugins.lsp.gopher")
	  end,
	  ft = { "go", "gomod" },
	},
  }
  
  -- Export the LSP configuration
  return lsp_config
  