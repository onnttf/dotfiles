-- |lang/lua.lua| — Lua language server and formatter config.
-- LSP: |lua-language-server|
return {
	lsp = {
		server       = "lua-language-server",
		cmd          = { "lua-language-server" },
		root_markers = { ".git", ".luarc.json", ".luarc.jsonc", "stylua.toml" },
	},
	formatter = { "stylua" },
}
