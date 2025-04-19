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

for lsp_name, config in pairs(lsp2Config) do
	config = vim.tbl_deep_extend("force", common_config, config)
	vim.lsp.config[lsp_name] = config
	local ok, err = pcall(vim.lsp.enable, { lsp_name })
	if not ok then
		vim.notify("Failed to enable LSP server: " .. lsp_name .. "\n" .. err, vim.log.levels.ERROR)
	end
end

local mappings = {
	{ "K", "textDocument/hover", vim.lsp.buf.hover, {
		desc = "Show hover",
	} },
	{ "gd", "textDocument/definition", vim.lsp.buf.definition, {
		desc = "[G]o to definition",
	} },
	{
		"<leader>oa",
		"textDocument/codeAction",
		"<Cmd>FzfLua lsp_code_actions previewer=false<CR>",
		{
			desc = "[O]perate code actions",
		},
	},
	{ "<leader>or", "textDocument/rename", vim.lsp.buf.rename, {
		desc = "[O]perate rename symbol",
	} },
	{
		"<leader>sds",
		"textDocument/documentSymbol",
		"<Cmd>FzfLua lsp_document_symbols previewer=false<CR>",
		{
			desc = "[S]how [d]ocument symbols",
		},
	},
	{ "<leader>sr", "textDocument/references", "<Cmd>FzfLua lsp_references<CR>", {
		desc = "[S]how references",
	} },
	{
		"<leader>sci",
		"callHierarchy/incomingCalls",
		"<Cmd>FzfLua lsp_incoming_calls<CR>",
		{
			desc = "[S]how incoming calls",
		},
	},
	{
		"<leader>sco",
		"callHierarchy/outgoingCalls",
		"<Cmd>FzfLua lsp_outgoing_calls<CR>",
		{
			desc = "[S]how outgoing calls",
		},
	},
	{
		"<leader>si",
		"textDocument/implementation",
		"<Cmd>FzfLua lsp_implementations<CR>",
		{
			desc = "[S]how implementation",
		},
	},
}

local keymap = require("util").keymap
local augroup = vim.api.nvim_create_augroup("user_config_lsp", {
	clear = true,
})

vim.api.nvim_create_autocmd("LspAttach", {
	group = augroup,
	desc = "Set up buffer-local keymaps and options for LSP",
	callback = function(event)
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		local bufnr = event.buf

		if not client then
			vim.notify("LSP client not found", vim.log.levels.ERROR)
			return
		end

		for _, map in ipairs(mappings) do
			local key, method, action, opts = unpack(map)
			if client:supports_method(method) then
				keymap(
					"n",
					key,
					action,
					vim.tbl_extend("force", opts, {
						buffer = bufnr,
					})
				)
			end
		end
	end,
})
