return {
	lsp = {
		server = "gopls",
		cmd = { "gopls" },
		root_markers = { "go.work", "go.mod", ".git" },
	},
	formatter = { "goimports", "gofumpt" },
}
