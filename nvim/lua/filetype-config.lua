-- Filetype configuration mapping LSP servers and formatters to specific filetypes

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
		},
		formatter = { "black" },
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
			server = "jsonls",
			cmd = { "vscode-json-language-server", "--stdio" },
		},
		formatter = { "prettier" },
	},
	jsonc = {
		lsp = { server = "jsonls" },
		formatter = { "prettier" },
	},
	yaml = {
		lsp = {
			server = "yamlls",
			cmd = { "yaml-language-server", "--stdio" },
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
		vim.notify(
			"Installing missing Mason tools: " .. table.concat(to_install, " "),
			vim.log.levels.INFO
		)
		vim.cmd("MasonInstall " .. table.concat(to_install, " "))
	end
end)
-- LSP configuration

-- Configure default LSP capabilities and root markers for all buffers
vim.lsp.config("*", {
	capabilities = {
		textDocument = {
			semanticTokens = {
				multilineTokenSupport = true,
			},
		},
	},
	root_markers = { ".git" },
})

-- Build LSP server configuration by merging filetype-specific configs
local lsp2Config = {}
local fileType2FormatterList = {}

for ft, cfg in pairs(filetype_config) do
	if cfg.lsp then
		local server = cfg.lsp.server
		if not lsp2Config[server] then
			lsp2Config[server] = vim.tbl_deep_extend("force", {}, cfg.lsp)
		else
			lsp2Config[server] = deep_merge(lsp2Config[server], cfg.lsp)
		end
		lsp2Config[server].filetypes = unique_list(
			vim.list_extend(lsp2Config[server].filetypes or {}, { ft })
		)
	end
	
	if cfg.formatter then
		fileType2FormatterList[ft] = cfg.formatter
	end
end

-- Enable LSP servers with their merged configurations
for server, cfg in pairs(lsp2Config) do
	vim.lsp.config[server] = cfg
	vim.lsp.enable({ server })
end

-- Formatter configuration
local ok, conform = pcall(require, "conform")
if ok then
	for ft, formatters in pairs(fileType2FormatterList) do
		conform.formatters_by_ft[ft] = formatters
	end
end
