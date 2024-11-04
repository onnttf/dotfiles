return {
	lua = {
		lsp = {
			lua_ls = {
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" },
						},
						workspace = { checkThirdParty = false },
						telemetry = { enable = false },
					},
				},
			},
		},
		formatter = { stylua = {} },
	},
	go = {
		lsp = {
			gopls = {
				settings = {
					gofumpt = true,
					semanticTokens = true,
					usePlaceholders = true,
					analyses = {
						shadow = true,
						unusedvariable = true,
						useany = true,
					},
					staticcheck = true,
					vulncheck = "Imports",
					hints = {
						assignVariableTypes = true,
						compositeLiteralFields = true,
						compositeLiteralTypes = true,
						constantValues = true,
						functionTypeParameters = true,
						parameterNames = true,
						rangeVariableTypes = true,
					},
				},
			},
		},
		formatter = { gofumpt = {}, goimports = {} },
		linter = { ["golangci-lint"] = {} },
	},
	php = {
		lsp = { intelephense = {} },
		formatter = { ["php-cs-fixer"] = {} },
	},
	python = {
		lsp = { pyright = {} },
		formatter = { black = {} },
	},
	typescript = {
		lsp = { ts_ls = {} },
	},
	json = {
		lsp = { jsonls = {} },
		formatter = { prettier = {} },
	},
	yaml = {
		lsp = { yamlls = {} },
		formatter = { prettier = {} },
	},
	bash = {
		lsp = { bashls = {} },
		formatter = { shfmt = {} },
	},
	sql = {
		lsp = { sqlls = {} },
		formatter = { ["sql-formatter"] = {} },
	},
	markdown = {
		linter = { ["markdownlint-cli2"] = {} },
		formatter = { ["markdownlint-cli2"] = {} },
	},
	css = {
		formatter = { prettier = {} },
	},
	less = {
		formatter = { prettier = {} },
	},
	html = {
		formatter = { prettier = {} },
	},
	javascript = {
		formatter = { prettier = {} },
	},
}
