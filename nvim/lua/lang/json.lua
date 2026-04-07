return {
	lsp = {
		server = "json_lsp",
		cmd = { "vscode-json-language-server", "--stdio" },
		root_markers = { ".git" },
	},
	formatter = { "prettier" },
}
