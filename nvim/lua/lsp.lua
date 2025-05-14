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

local keymap = require("util").keymap
local wk = require("which-key")

keymap("n", "<leader>sdd", "<cmd>FzfLua diagnostics_document<CR>", {
	desc = "[S]how [d]ocument diagnostics",
})
keymap("n", "<leader>swd", "<cmd>FzfLua diagnostics_workspace<CR>", {
	desc = "[S]how [w]orkspace diagnostics",
})
wk.add({ {
	"<leader>s",
	desc = "[S]how-related keymaps",
} })

vim.api.nvim_create_autocmd("LspAttach", {
	group = augroup,
	callback = function(args)
		local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
		local bufnr = args.buf

		if client:supports_method("textDocument/foldingRange") then
			local win = vim.api.nvim_get_current_win()
			vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
		end

		-- [S]how-related keymaps
		if client:supports_method("textDocument/hover") then
			keymap("n", "K", function()
				vim.lsp.buf.hover({
					border = "rounded",
					max_height = 10,
				})
			end, {
				buffer = bufnr,
				desc = "Show hover",
			})
		end

		if client:supports_method("textDocument/documentSymbol") then
			keymap("n", "<leader>sds", "<Cmd>FzfLua lsp_document_symbols previewer=false<CR>", {
				buffer = bufnr,
				desc = "[S]how [d]ocument symbols",
			})
			wk.add({ {
				"<leader>s",
				desc = "[S]how-related keymaps",
			} })
		end

		if client:supports_method("textDocument/references") then
			keymap("n", "<leader>sr", "<Cmd>FzfLua lsp_references<CR>", {
				buffer = bufnr,
				desc = "[S]how references",
			})
			wk.add({ {
				"<leader>s",
				desc = "[S]how-related keymaps",
			} })
		end

		if client:supports_method("callHierarchy/incomingCalls") then
			keymap("n", "<leader>sci", "<Cmd>FzfLua lsp_incoming_calls<CR>", {
				buffer = bufnr,
				desc = "[S]how incoming calls",
			})
			wk.add({ {
				"<leader>s",
				desc = "[S]how-related keymaps",
			} })
		end

		if client:supports_method("callHierarchy/outgoingCalls") then
			keymap("n", "<leader>sco", "<Cmd>FzfLua lsp_outgoing_calls<CR>", {
				buffer = bufnr,
				desc = "[S]how outgoing calls",
			})
			wk.add({ {
				"<leader>s",
				desc = "[S]how-related keymaps",
			} })
		end

		if client:supports_method("textDocument/implementation") then
			keymap("n", "<leader>si", "<Cmd>FzfLua lsp_implementations<CR>", {
				buffer = bufnr,
				desc = "[S]how implementation",
			})
			wk.add({ {
				"<leader>s",
				desc = "[S]how-related keymaps",
			} })
		end

		-- [G]o-related keymaps
		if client:supports_method("textDocument/definition") then
			keymap("n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", {
				buffer = bufnr,
				desc = "[G]o to definition",
			})
		end

		-- [O]perate-related keymaps
		if client:supports_method("textDocument/codeAction") then
			keymap("n", "<leader>oa", "<Cmd>FzfLua lsp_code_actions previewer=false<CR>", {
				buffer = bufnr,
				desc = "[O]perate code actions",
			})
			wk.add({ {
				"<leader>o",
				desc = "[O]perate-related keymaps",
			} })
		end

		if client:supports_method("textDocument/rename") then
			keymap("n", "<leader>or", function()
				vim.lsp.buf.rename()
			end, {
				buffer = bufnr,
				desc = "[O]perate rename symbol",
			})
			wk.add({ {
				"<leader>o",
				desc = "[O]perate-related keymaps",
			} })
		end
	end,
})
