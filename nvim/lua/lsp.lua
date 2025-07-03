-- [[ LSP Configuration ]]

-- Common configurations to apply to all LSP clients.
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

-- Individual language server configurations.
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

-- Apply common configurations and set up individual LSP servers.
vim.lsp.config("*", common_config)

for lsp_name, config in pairs(lsp_configs) do
	vim.lsp.config[lsp_name] = config
	vim.lsp.enable({ lsp_name })
end

-- Autocommand group for LSP-related configurations.
local lsp_augroup = vim.api.nvim_create_augroup("user_config_lsp", {
	clear = true,
})

-- Assuming 'keymap' is defined in 'util.lua'.
local keymap = require("util").keymap
local wk = require("which-key")

-- General diagnostics keymaps.
keymap("n", "<leader>sdd", "<cmd>FzfLua diagnostics_document<CR>", {
	desc = "Show: Document diagnostics",
})
keymap("n", "<leader>swd", "<cmd>FzfLua diagnostics_workspace<CR>", {
	desc = "Show: Workspace diagnostics",
})

-- Which-key group for 'show' related keymaps.
wk.add({ {
	"<leader>s",
	desc = "[S]how actions",
} })

-- Define LSP-specific keymaps and settings when a language server attaches.
vim.api.nvim_create_autocmd("LspAttach", {
	group = lsp_augroup,
	callback = function(args)
		local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
		local bufnr = args.buf

		-- Enable LSP-based folding if supported.
		if client:supports_method("textDocument/foldingRange") then
			vim.wo[0].foldmethod = "expr"
			vim.wo[0].foldexpr = "v:lua.vim.lsp.foldexpr()"
		end

		-- Keymaps contingent on LSP client capabilities:
		-- Show hover information.
		if client:supports_method("textDocument/hover") then
			keymap("n", "K", function()
				vim.lsp.buf.hover({
					border = "rounded",
					max_height = 10,
				})
			end, {
				buffer = bufnr,
				desc = "Show: Hover info",
			})
		end

		-- Show document symbols.
		if client:supports_method("textDocument/documentSymbol") then
			keymap("n", "<leader>sds", "<Cmd>FzfLua lsp_document_symbols previewer=false<CR>", {
				buffer = bufnr,
				desc = "Show: Document symbols",
			})
		end

		-- Show references.
		if client:supports_method("textDocument/references") then
			keymap("n", "<leader>sr", "<Cmd>FzfLua lsp_references<CR>", {
				buffer = bufnr,
				desc = "Show: References",
			})
		end

		-- Show incoming call hierarchy.
		if client:supports_method("callHierarchy/incomingCalls") then
			keymap("n", "<leader>sci", "<Cmd>FzfLua lsp_incoming_calls<CR>", {
				buffer = bufnr,
				desc = "Show: Incoming calls",
			})
		end

		-- Show outgoing call hierarchy.
		if client:supports_method("callHierarchy/outgoingCalls") then
			keymap("n", "<leader>sco", "<Cmd>FzfLua lsp_outgoing_calls<CR>", {
				buffer = bufnr,
				desc = "Show: Outgoing calls",
			})
		end

		-- Show implementations.
		if client:supports_method("textDocument/implementation") then
			keymap("n", "<leader>si", "<Cmd>FzfLua lsp_implementations<CR>", {
				buffer = bufnr,
				desc = "Show: Implementations",
			})
		end

		-- Go to definition.
		if client:supports_method("textDocument/definition") then
			keymap("n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", {
				buffer = bufnr,
				desc = "Go to: Definition",
			})
		end

		-- Operate on code actions.
		if client:supports_method("textDocument/codeAction") then
			keymap("n", "<leader>oa", "<Cmd>FzfLua lsp_code_actions previewer=false<CR>", {
				buffer = bufnr,
				desc = "Operate: Code actions",
			})
		end

		-- Operate on symbol rename.
		if client:supports_method("textDocument/rename") then
			keymap("n", "<leader>or", function()
				vim.lsp.buf.rename()
			end, {
				buffer = bufnr,
				desc = "Operate: Rename symbol",
			})
		end

		-- Add 'Operate' which-key group.
		wk.add({
			{ "<leader>o", desc = "[O]perate actions", mode = { "n" }, buffer = bufnr },
		})
	end,
})

