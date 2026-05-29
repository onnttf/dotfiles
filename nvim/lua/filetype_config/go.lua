return {
	lsp = vim.deepcopy(require("lsp_config.gopls")),
	formatters = { "goimports", "gofumpt" },
}
