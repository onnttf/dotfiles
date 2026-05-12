-- |lang/json.lua| — JSON language server config.
-- LSP: |vscode-json-language-server|
return {
	lsp = {
		server       = "json_lsp",
		cmd          = { "vscode-json-language-server", "--stdio" },
		root_markers = { ".git" },
	},
	formatter = { "prettier" },
}
