-- LSP configuration setup
local lsp_config = {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
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
					{
						"windwp/nvim-autopairs",
						config = function()
							require("plugins.lsp.nvim-autopairs")
						end,
					},
				},
				config = function()
					require("plugins.lsp.nvim-cmp")
				end,
			},
		},
		event = { "BufReadPre", "BufNewFile" },
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
	--{
	--	"ray-x/go.nvim",
	--	dependencies = { "ray-x/guihua.lua" },
	--	config = function()
	--		require("plugins.lsp.go")
	--	end,
	--	ft = { "go", "gomod" },
	--	build = ':lua require("go.install").update_all_sync()', -- Install/update all binaries if needed
	--},
}

-- Export the LSP configuration
return lsp_config
