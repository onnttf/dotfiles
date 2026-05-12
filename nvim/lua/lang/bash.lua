-- |lang/bash.lua| — Bash/Shell language server config.
-- LSP: |bash-language-server|
return {
	lsp = {
		server = "bashls",
		cmd    = { "bash-language-server", "start" },
	},
	formatter = { "shfmt" },
}
