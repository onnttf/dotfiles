return {
	lsp = {
		server = "yaml-language-server",
		cmd = { "yaml-language-server", "--stdio" },
		root_markers = { ".git" },
	},
	formatter = { "prettier" },
}
