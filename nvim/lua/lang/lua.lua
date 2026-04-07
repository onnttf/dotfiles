return {
	lsp = {
		server = "lua-language-server",
		cmd = { "lua-language-server" },
		root_markers = { ".git", ".luarc.json", ".luarc.jsonc", "stylua.toml" },
	},
	formatter = { "stylua" },
}
