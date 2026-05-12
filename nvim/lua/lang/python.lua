-- |lang/python.lua| — Python language server configuration.
-- LSP: |pyright|
return {
	lsp = {
		server       = "pyright",
		cmd          = { "pyright-langserver", "--stdio" },
		root_markers = { "pyrightconfig.json", "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", ".git" },
		settings = {
			python = {
				analysis = {
					autoSearchPaths       = true,
					useLibraryCodeForTypes = true,
					diagnosticMode        = "openFilesOnly",
				},
			},
		},
	},
}
