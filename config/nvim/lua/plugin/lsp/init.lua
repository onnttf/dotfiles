local lsp_config = {
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
					require("plugin.lsp.nvim-cmp")
				end,
			},
		},
		config = function()
			require("plugin.lsp.nvim-lspconfig")
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
}

return lsp_config
