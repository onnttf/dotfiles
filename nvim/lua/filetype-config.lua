vim.env.PATH = vim.env.PATH .. ":" .. vim.fn.expand("~/.local/share/nvim/mason/bin")

local filetype_config = {
	-- Default formatter for all filetypes
	["*"] = {
		formatter = { "codespell" },
	},

	-- Go ecosystem
	go = {
		lsp = {
			server = "gopls",
			cmd = { "gopls" },
			root_markers = { "go.work", "go.mod", ".git" },
		},
		formatter = { "goimports", "gofumpt" },
	},
	gomod = {
		lsp = { server = "gopls" },
		formatter = { "goimports" },
	},
	gowork = {
		lsp = { server = "gopls" },
		formatter = { "goimports" },
	},
	gotmpl = {
		lsp = { server = "gopls" },
		formatter = { "goimports" },
	},

	-- Python
	python = {
		lsp = {
			server = "pyright",
			cmd = { "pyright-langserver", "--stdio" },
			root_markers = {
				"pyrightconfig.json",
				"pyproject.toml",
				"setup.py",
				"setup.cfg",
				"requirements.txt",
				"Pipfile",
				".git",
			},
			settings = {
				python = {
					analysis = {
						autoSearchPaths = true,
						useLibraryCodeForTypes = true,
						diagnosticMode = "openFilesOnly",
					},
				},
			},
		},
		--formatter = { "black" },
	},

	-- TypeScript/JavaScript
	javascript = {
		lsp = {
			server = "ts_ls",
			cmd = { "typescript-language-server", "--stdio" },
			root_markers = { "package.json", "package-lock.json", "yarn.lock", "pnpm-lock.yaml", ".git" },
		},
	},
	javascriptreact = {
		lsp = { server = "ts_ls" },
	},
	typescript = {
		lsp = { server = "ts_ls" },
	},
	typescriptreact = {
		lsp = { server = "ts_ls" },
	},

	-- Lua
	lua = {
		lsp = {
			server = "lua-language-server",
			cmd = { "lua-language-server" },
		},
		formatter = { "stylua" },
	},

	-- Configuration files
	json = {
		lsp = {
			server = "json-lsp",
			cmd = { "vscode-json-language-server", "--stdio" },
			root_markers = { ".git" },
		},
		formatter = { "prettier" },
	},
	jsonc = {
		lsp = { server = "json-lsp" },
		formatter = { "prettier" },
	},
	yaml = {
		lsp = {
			server = "yaml-language-server",
			cmd = { "yaml-language-server", "--stdio" },
			root_markers = { ".git" },
		},
		formatter = { "prettier" },
	},

	-- Shell scripts
	bash = {
		lsp = {
			server = "bashls",
			cmd = { "bash-language-server", "start" },
		},
		formatter = { "shfmt" },
	},
	sh = {
		lsp = { server = "bashls" },
		formatter = { "shfmt" },
	},
}
-- Utility functions

--- Removes duplicate values from a list while preserving order
local function unique_list(tbl)
	local seen, res = {}, {}
	for _, v in ipairs(tbl or {}) do
		if not seen[v] then
			seen[v] = true
			table.insert(res, v)
		end
	end
	return res
end

--- Recursively merges two tables, concatenating lists instead of replacing them
local function deep_merge(existing, new)
	if type(existing) ~= "table" then
		return new
	end
	if type(new) ~= "table" then
		return new
	end

	local res = vim.tbl_deep_extend("force", {}, existing)
	for k, v in pairs(new) do
		if type(v) == "table" and type(res[k]) == "table" then
			if vim.tbl_islist(v) then
				res[k] = unique_list(vim.list_extend(res[k], v))
			else
				res[k] = deep_merge(res[k], v)
			end
		else
			res[k] = v
		end
	end
	return res
end
-- Mason tool management

-- Collect all required LSP servers and formatters for Mason installation
local mason_tools = {}
for _, cfg in pairs(filetype_config) do
	if cfg.lsp then
		table.insert(mason_tools, cfg.lsp.server)
	end
	if cfg.formatter then
		for _, f in ipairs(cfg.formatter) do
			table.insert(mason_tools, f)
		end
	end
end
mason_tools = unique_list(mason_tools)

-- Schedule Mason tool installation after Neovim startup
vim.schedule(function()
	local registry = require("mason-registry")
	local to_install = {}

	for _, tool in ipairs(mason_tools) do
		local ok, pkg = pcall(registry.get_package, tool)
		if ok and pkg and not pkg:is_installed() then
			table.insert(to_install, tool)
		end
	end

	if #to_install > 0 then
		vim.notify("Installing missing Mason tools: " .. table.concat(to_install, " "), vim.log.levels.INFO)
		vim.cmd("MasonInstall " .. table.concat(to_install, " "))
	end
end)
-- LSP configuration
local on_attach = function(client, bufnr)
	vim.opt.omnifunc = "v:lua.vim.lsp.omnifunc"
	vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr, desc = "Go to definition" })
	vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = bufnr, desc = "Go to declaration" })
	vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = bufnr, desc = "References" })
	vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { buffer = bufnr, desc = "Go to implementation" })
	vim.keymap.set("n", "go", vim.lsp.buf.type_definition, { buffer = bufnr, desc = "Go to type definition" })
	vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr, desc = "Hover" })
	vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr, desc = "Code action" })
	vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { buffer = bufnr, desc = "Rename" })
end

vim.lsp.config("*", {
	on_attach = on_attach,
	capabilities = {
		textDocument = {
			semanticTokens = { multilineTokenSupport = true },
			completion = { completionItem = { snippetSupport = true } },
		},
		workspace = {
			workspaceFolders = true,
		},
	},
})

-- Build LSP server and formatter configuration
local lsp_config = {}
local ft_formatters = {}

for ft, cfg in pairs(filetype_config) do
	if cfg.lsp then
		local server = cfg.lsp.server
		if not lsp_config[server] then
			lsp_config[server] = vim.tbl_deep_extend("force", {}, cfg.lsp)
		else
			lsp_config[server] = deep_merge(lsp_config[server], cfg.lsp)
		end
		lsp_config[server].filetypes = vim.list_extend(lsp_config[server].filetypes or {}, { ft })
	end

	if cfg.formatter then
		ft_formatters[ft] = cfg.formatter
	end
end

for server, cfg in pairs(lsp_config) do
	cfg.filetypes = unique_list(cfg.filetypes)
	vim.lsp.config[server] = cfg
	vim.lsp.enable({ server })
end

-- Formatter configuration
local ok, conform = pcall(require, "conform")
if ok then
	for ft, formatters in pairs(ft_formatters) do
		conform.formatters_by_ft[ft] = formatters
	end
end
