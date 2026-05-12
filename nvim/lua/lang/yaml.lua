-- |lang/yaml.lua| — YAML language server config.
-- LSP: |yaml-language-server|
return {
	lsp = {
		server       = "yaml-language-server",
		cmd          = { "yaml-language-server", "--stdio" },
		root_markers = { ".git" },
	},
	formatter = { "prettier" },
}
