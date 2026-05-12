-- |lang/typescript.lua| — TypeScript/JavaScript/React language server config.
-- LSP: |ts_ls|
return {
	lsp = {
		server       = "ts_ls",
		cmd          = { "typescript-language-server", "--stdio" },
		root_markers = { "package.json", "package-lock.json", "yarn.lock", "pnpm-lock.yaml", ".git" },
	},
	formatter = { "prettier" },
}
