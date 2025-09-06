local common_config = {
	capabilities = {
		textDocument = {
			semanticTokens = {
				multilineTokenSupport = true,
			},
		},
	},
	root_markers = { ".git" },
}

local lsp_configs = {
	gopls = {
		cmd = { "gopls" },
		filetypes = { "go", "gomod", "gowork", "gotmpl" },
		root_markers = { "go.work", "go.mod", ".git" },
		settings = {
			gopls = {
				usePlaceholders = true,
			},
		},
	},
	sqlls = {
		cmd = { "sql-language-server", "up", "--method", "stdio" },
		filetypes = { "sql", "mysql" },
	},
	pyright = {
		cmd = { "pyright-langserver", "--stdio" },
		filetypes = { "python" },
	},
	lua_ls = {
		cmd = { "lua-language-server" },
		filetypes = { "lua" },
		settings = {
			Lua = {
				runtime = {
					version = "LuaJIT",
				},
				diagnostics = {
					globals = { "vim" },
				},
			},
		},
	},
	intelephense = {
		cmd = { "intelephense", "--stdio" },
		filetypes = { "php" },
	},
	jsonls = {
		cmd = { "vscode-json-language-server", "--stdio" },
		filetypes = { "json", "jsonc" },
	},
	yamlls = {
		cmd = { "yaml-language-server", "--stdio" },
		filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab" },
	},
	bashls = {
		cmd = { "bash-language-server", "start" },
		filetypes = { "bash", "sh" },
	},
}

vim.lsp.config("*", common_config)

for lsp_name, config in pairs(lsp_configs) do
	vim.lsp.config[lsp_name] = config
	vim.lsp.enable({ lsp_name })
end
