-- https://github.com/folke/which-key.nvim
return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		icons = {
			mappings = false,
		},
		spec = {
			{ "<leader>b", group = "Buffer" },
			{ "<leader>c", group = "Copy" },
			{ "<leader>d", group = "Debug" },
			{ "<leader>g", group = "Git" },
			{ "<leader>l", group = "LSP" },
			{ "<leader>q", group = "Quickfix" },
			{ "<leader>s", group = "Search" },
			{ "<leader>w", group = "Workspace" },
			{ "<leader>x", group = "Diagnostics" },
			{ "gr", group = "LSP" },
			{ "[", group = "Previous" },
			{ "]", group = "Next" },
		},
	},
}
