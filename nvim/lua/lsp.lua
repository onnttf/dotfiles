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

local lsp2Config = {
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

for lsp_name, config in pairs(lsp2Config) do
	vim.lsp.config[lsp_name] = config
	vim.lsp.enable({ lsp_name })
end

local augroup = vim.api.nvim_create_augroup("user_config_lsp", {
	clear = true,
})

vim.api.nvim_create_autocmd("LspAttach", {
	group = augroup,
	callback = function(args)
		local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

		local keymap = require("util").keymap

		if client:supports_method("textDocument/hover") then
			keymap("n", "K", function()
				vim.lsp.buf.hover({
					border = "rounded",
					max_height = 10,
				})
			end, {
				buffer = args.buf,
				desc = "Show hover documentation",
			})
		end

		if client:supports_method("textDocument/codeAction") then
			keymap("n", "gra", "<Cmd>FzfLua lsp_code_actions previewer=false<CR>", {
				buffer = args.buf,
				desc = "Show code actions",
			})
		end

		if client:supports_method("textDocument/definition") then
			keymap("n", "gd", "<Cmd>FzfLua lsp_definitions<CR>", {
				buffer = args.buf,
				desc = "Go to definition",
			})
		end

		if client:supports_method("textDocument/implementation") then
			keymap("n", "gi", "<Cmd>FzfLua lsp_implementations<CR>", {
				buffer = args.buf,
				desc = "Go to implementation",
			})
		end

		if client:supports_method("textDocument/typeDefinition") then
			keymap("n", "gy", "<Cmd>FzfLua lsp_typedefs<CR>", {
				buffer = args.buf,
				desc = "Go to type definition",
			})
		end

		if client:supports_method("textDocument/documentSymbol") then
			keymap("n", "gO", "<Cmd>FzfLua lsp_document_symbols previewer=false<CR>", {
				buffer = args.buf,
				desc = "Show document symbols",
			})
		end

		if client:supports_method("textDocument/references") then
			keymap("n", "gr", "<Cmd>FzfLua lsp_references<CR>", {
				buffer = args.buf,
				desc = "Show references",
			})
		end

		if client:supports_method("callHierarchy/incomingCalls") then
			keymap("n", "g(", "<Cmd>FzfLua lsp_incoming_calls<CR>", {
				buffer = args.buf,
				desc = "Show incoming calls",
			})
		end

		if client:supports_method("callHierarchy/outgoingCalls") then
			keymap("n", "g)", "<Cmd>FzfLua lsp_outgoing_calls<CR>", {
				buffer = args.buf,
				desc = "Show outgoing calls",
			})
		end
	end,
})
