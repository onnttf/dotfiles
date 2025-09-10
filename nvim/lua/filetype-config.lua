local filetype_config = {
	["*"] = {
		formatter = { "codespell" },
	},
	go = {
		lsp = {
			server = "gopls",
			cmd = { "gopls" },
			root_markers = { "go.work", "go.mod", ".git" },
		},
		formatter = { "goimports", "gofumpt" },
	},
	gomod = {
		lsp = {
			server = "gopls",
		},
		formatter = { "goimports" },
	},
	gowork = {
		lsp = {
			server = "gopls",
		},
		formatter = { "goimports" },
	},
	gotmpl = {
		lsp = {
			server = "gopls",
		},
		formatter = { "goimports" },
	},
	python = {
		lsp = {
			server = "pyright",
			cmd = { "pyright-langserver", "--stdio" },
		},
		formatter = { "black" },
	},
	lua = {
		lsp = {
			server = "lua-language-server",
			cmd = { "lua-language-server" },
		},
		formatter = { "stylua" },
	},
	json = {
		lsp = {
			server = "jsonls",
			cmd = { "vscode-json-language-server", "--stdio" },
		},
		formatter = { "prettier" },
	},
	jsonc = {
		lsp = {
			server = "jsonls",
		},
		formatter = { "prettier" },
	},
	yaml = {
		lsp = {
			server = "yamlls",
			cmd = { "yaml-language-server", "--stdio" },
		},
		formatter = { "prettier" },
	},
	bash = {
		lsp = {
			server = "bashls",
			cmd = { "bash-language-server", "start" },
		},
		formatter = { "shfmt" },
	},
	sh = {
		lsp = {
			server = "bashls",
		},
		formatter = { "shfmt" },
	},
}

local function unique_list(tbl)
	local seen = {}
	local res = {}
	for _, v in ipairs(tbl) do
		if not seen[v] then
			table.insert(res, v)
			seen[v] = true
		end
	end
	return res
end

local function deep_merge(existing, new)
	if type(existing) ~= "table" then
		return new
	end
	if type(new) ~= "table" then
		return new
	end
	local res = vim.tbl_deep_extend("force", {}, existing)
	for k, v in pairs(new) do
		if type(v) == "table" then
			if type(res[k]) == "table" then
				if vim.tbl_islist(v) then
					res[k] = unique_list(vim.list_extend(res[k], v))
				else
					res[k] = deep_merge(res[k], v)
				end
			else
				res[k] = v
			end
		else
			res[k] = v
		end
	end
	return res
end

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
vim.lsp.config("*", common_config)

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
		lsp2Config[server].filetypes = unique_list(vim.list_extend(lsp2Config[server].filetypes or {}, { ft }))
	end
	if cfg.formatter then
		fileType2FormatterList[ft] = cfg.formatter
	end
end

for server, cfg in pairs(lsp2Config) do
	vim.lsp.config[server] = cfg
	vim.lsp.enable({ server })
end

for ft, formatters in pairs(fileType2FormatterList) do
	require("conform").formatters_by_ft[ft] = formatters
end

local ok, conform = pcall(require, "conform")
if ok then
	for fileType, formatters in pairs(fileType2FormatterList) do
		conform.formatters_by_ft[fileType] = formatters
	end
end
