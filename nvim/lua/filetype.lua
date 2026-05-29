local on_attach = function(client, bufnr)
	local function map(mode, lhs, rhs, desc)
		vim.keymap.set(mode, lhs, rhs, {
			buffer = bufnr,
			silent = true,
			noremap = true,
			desc = desc,
		})
	end

	local function supports(method)
		return client:supports_method(method, bufnr)
	end

	local function diagnostic_jump(count, severity)
		return function()
			vim.diagnostic.jump({
				count = count,
				severity = severity and { min = severity } or nil,
			})
		end
	end

	local function code_action(kind)
		return function()
			vim.lsp.buf.code_action({
				context = {
					only = kind and { kind } or nil,
					diagnostics = vim.diagnostic.get(bufnr),
				},
			})
		end
	end

	local function format()
		local ok, conform = pcall(require, "conform")

		if ok then
			conform.format({
				bufnr = bufnr,
				async = false,
				lsp_format = "fallback",
			})
			return
		end

		vim.lsp.buf.format({
			bufnr = bufnr,
			async = false,
		})
	end

	local function toggle_inlay_hints()
		vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), {
			bufnr = bufnr,
		})
	end

	local function toggle_semantic_tokens()
		vim.lsp.semantic_tokens.enable(not vim.lsp.semantic_tokens.is_enabled({ bufnr = bufnr }), {
			bufnr = bufnr,
			client_id = client.id,
		})
	end

	local function type_hierarchy()
		vim.ui.select(
			{ "supertypes", "subtypes" },
			{ prompt = "Type hierarchy:", kind = "typehierarchy" },
			function(kind)
				if kind then
					vim.lsp.buf.typehierarchy(kind)
				end
			end
		)
	end

	-- LSP meta.
	map("n", "<leader>cl", "<cmd>checkhealth vim.lsp<cr>", "LSP: Info")
	map("n", "<leader>ll", "<cmd>log lsp<cr>", "LSP: Log")

	-- Navigation.
	if supports("textDocument/definition") then
		map("n", "gd", vim.lsp.buf.definition, "LSP: Go to definition")
	end

	if supports("textDocument/declaration") then
		map("n", "gD", vim.lsp.buf.declaration, "LSP: Go to declaration")
	end

	if supports("textDocument/implementation") then
		map("n", "gri", vim.lsp.buf.implementation, "LSP: Go to implementation")
	end

	if supports("textDocument/typeDefinition") then
		map("n", "grt", vim.lsp.buf.type_definition, "LSP: Go to type definition")
	end

	if supports("textDocument/references") then
		map("n", "grr", vim.lsp.buf.references, "LSP: List references")
	end

	-- Symbols.
	if supports("textDocument/documentSymbol") then
		map("n", "gO", vim.lsp.buf.document_symbol, "LSP: Document symbols")
		map("n", "<leader>ss", vim.lsp.buf.document_symbol, "LSP: Document symbols")
	end

	if supports("workspace/symbol") then
		map("n", "<leader>sS", vim.lsp.buf.workspace_symbol, "LSP: Workspace symbols")
	end

	-- Documentation.
	if supports("textDocument/hover") then
		map("n", "K", vim.lsp.buf.hover, "LSP: Hover")
	end

	if supports("textDocument/signatureHelp") then
		map({ "i", "s" }, "<C-s>", vim.lsp.buf.signature_help, "LSP: Signature help")
		map("n", "gK", vim.lsp.buf.signature_help, "LSP: Signature help")
	end

	-- Code actions.
	if supports("textDocument/rename") then
		map("n", "grn", vim.lsp.buf.rename, "LSP: Rename")
		map("n", "<leader>cr", vim.lsp.buf.rename, "LSP: Rename")
	end

	if supports("textDocument/codeAction") then
		map({ "n", "x" }, "gra", vim.lsp.buf.code_action, "LSP: Code action")
		map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "LSP: Code action")
		map("n", "<leader>cA", code_action("source"), "LSP: Source action")
		map("n", "<leader>co", code_action("source.organizeImports"), "LSP: Organize imports")
	end

	-- Formatting.
	if supports("textDocument/formatting") or supports("textDocument/rangeFormatting") then
		map({ "n", "x" }, "<leader>cf", format, "LSP: Format")
	end

	-- Code lens.
	if supports("textDocument/codeLens") then
		map("n", "grx", vim.lsp.codelens.run, "LSP: Run code lens")
		map("n", "<leader>cc", vim.lsp.codelens.run, "LSP: Run code lens")
		map("n", "<leader>cR", function()
			vim.lsp.codelens.refresh({ bufnr = bufnr })
		end, "LSP: Refresh code lens")
	end

	-- Workspace folders.
	map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, "LSP: Add workspace folder")
	map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, "LSP: Remove workspace folder")

	map("n", "<leader>wl", function()
		vim.print(vim.lsp.buf.list_workspace_folders())
	end, "LSP: List workspace folders")

	-- Inlay hints.
	if supports("textDocument/inlayHint") then
		map("n", "<leader>li", toggle_inlay_hints, "LSP: Toggle inlay hints")
	end

	-- Semantic tokens.
	if supports("textDocument/semanticTokens/full") or supports("textDocument/semanticTokens/range") then
		map("n", "<leader>lt", toggle_semantic_tokens, "LSP: Toggle semantic tokens")

		map("n", "<leader>lT", function()
			vim.lsp.semantic_tokens.force_refresh(bufnr)
		end, "LSP: Refresh semantic tokens")
	end

	-- Document colors.
	if vim.lsp.document_color and supports("textDocument/documentColor") then
		map("n", "<leader>lc", function()
			vim.lsp.document_color.enable(not vim.lsp.document_color.is_enabled({ bufnr = bufnr }), {
				bufnr = bufnr,
				client_id = client.id,
			})
		end, "LSP: Toggle document colors")

		map("n", "<leader>cp", vim.lsp.document_color.color_presentation, "LSP: Color presentation")
	end

	-- Linked editing.
	if vim.lsp.linked_editing_range and supports("textDocument/linkedEditingRange") then
		map("n", "<leader>le", function()
			vim.lsp.linked_editing_range.enable(true, {
				bufnr = bufnr,
				client_id = client.id,
			})
		end, "LSP: Enable linked editing")
	end

	-- Call hierarchy.
	if supports("callHierarchy/incomingCalls") then
		map("n", "<leader>lci", vim.lsp.buf.incoming_calls, "LSP: Incoming calls")
	end

	if supports("callHierarchy/outgoingCalls") then
		map("n", "<leader>lco", vim.lsp.buf.outgoing_calls, "LSP: Outgoing calls")
	end

	-- Type hierarchy.
	if supports("textDocument/prepareTypeHierarchy") then
		map("n", "<leader>lH", type_hierarchy, "LSP: Type hierarchy")
	end

	-- Folding.
	if supports("textDocument/foldingRange") then
		vim.wo[0].foldmethod = "expr"
		vim.wo[0].foldexpr = "v:lua.vim.lsp.foldexpr()"

		vim.api.nvim_create_autocmd("LspNotify", {
			buffer = bufnr,
			callback = function(ev)
				if ev.data.method == "textDocument/didOpen" then
					vim.lsp.foldclose("imports", vim.fn.bufwinid(bufnr))
				end
			end,
		})
	end

	-- Document highlight.
	if supports("textDocument/documentHighlight") then
		local group = vim.api.nvim_create_augroup("lsp_document_highlight_" .. bufnr, {
			clear = true,
		})

		vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
			group = group,
			buffer = bufnr,
			callback = vim.lsp.buf.document_highlight,
		})

		vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
			group = group,
			buffer = bufnr,
			callback = vim.lsp.buf.clear_references,
		})

		vim.api.nvim_create_autocmd("LspDetach", {
			group = group,
			buffer = bufnr,
			callback = function()
				vim.lsp.buf.clear_references()
				vim.api.nvim_clear_autocmds({ group = group, buffer = bufnr })
			end,
		})
	end

	-- Diagnostics.
	map("n", "[d", diagnostic_jump(-1), "Diagnostic: Previous")
	map("n", "]d", diagnostic_jump(1), "Diagnostic: Next")
	map("n", "[D", diagnostic_jump(-math.huge), "Diagnostic: First")
	map("n", "]D", diagnostic_jump(math.huge), "Diagnostic: Last")

	map("n", "[e", diagnostic_jump(-1, vim.diagnostic.severity.ERROR), "Diagnostic: Previous error")
	map("n", "]e", diagnostic_jump(1, vim.diagnostic.severity.ERROR), "Diagnostic: Next error")

	map("n", "[w", diagnostic_jump(-1, vim.diagnostic.severity.WARN), "Diagnostic: Previous warning")
	map("n", "]w", diagnostic_jump(1, vim.diagnostic.severity.WARN), "Diagnostic: Next warning")

	map("n", "[i", diagnostic_jump(-1, vim.diagnostic.severity.INFO), "Diagnostic: Previous info")
	map("n", "]i", diagnostic_jump(1, vim.diagnostic.severity.INFO), "Diagnostic: Next info")

	map("n", "[h", diagnostic_jump(-1, vim.diagnostic.severity.HINT), "Diagnostic: Previous hint")
	map("n", "]h", diagnostic_jump(1, vim.diagnostic.severity.HINT), "Diagnostic: Next hint")

	-- Diagnostic UI.
	map("n", "gl", vim.diagnostic.open_float, "Diagnostic: Open float")
	map("n", "<leader>xd", vim.diagnostic.open_float, "Diagnostic: Line diagnostics")
	map("n", "<leader>xl", vim.diagnostic.setloclist, "Diagnostic: Set location list")
	map("n", "<leader>xq", vim.diagnostic.setqflist, "Diagnostic: Set quickfix list")
	map("n", "<leader>xD", vim.diagnostic.setqflist, "Diagnostic: All diagnostics")

	if supports("workspace/diagnostic") then
		map("n", "<leader>xw", function()
			vim.lsp.buf.workspace_diagnostics({ client_id = client.id })
		end, "Diagnostic: Workspace diagnostics")
	end
end

local server_to_mason = {
	ts_ls = "ts-ls",
	lua_ls = "lua-language-server",
	jsonls = "vscode-json-language-server",
	yamlls = "yaml-language-server",
	bashls = "bash-language-server",
}

local global_formatters = { "codespell" }

local filetype_configs = {
	{ filetype = "go", module = "filetype_config.go" },
	{ filetype = "gomod", module = "filetype_config.gomod" },
	{ filetype = "gowork", module = "filetype_config.gowork" },
	{ filetype = "gotmpl", module = "filetype_config.gotmpl" },

	{ filetype = "python", module = "filetype_config.python" },

	{ filetype = "javascript", module = "filetype_config.typescript" },
	{ filetype = "javascriptreact", module = "filetype_config.typescript" },
	{ filetype = "typescript", module = "filetype_config.typescript" },
	{ filetype = "typescriptreact", module = "filetype_config.typescript" },

	{ filetype = "lua", module = "filetype_config.lua" },

	{ filetype = "json", module = "filetype_config.json" },
	{ filetype = "jsonc", module = "filetype_config.json" },

	{ filetype = "yaml", module = "filetype_config.yaml" },

	{ filetype = "bash", module = "filetype_config.bash" },
	{ filetype = "sh", module = "filetype_config.bash" },
}

local function is_list(value)
	return type(value) == "table" and vim.islist(value)
end

local function join_path(path, key)
	if path == "" then
		return tostring(key)
	end

	return path .. "." .. tostring(key)
end

local function merge_lsp(a, b, path)
	path = path or ""

	local result = vim.deepcopy(a)

	for key, b_value in pairs(b) do
		local a_value = result[key]
		local key_path = join_path(path, key)

		if a_value == nil then
			result[key] = vim.deepcopy(b_value)
		elseif is_list(a_value) and is_list(b_value) then
			result[key] = vim.list.unique(vim.list_extend(vim.list_extend({}, a_value), b_value))
		elseif type(a_value) == "table" and type(b_value) == "table" then
			result[key] = merge_lsp(a_value, b_value, key_path)
		elseif vim.deep_equal(a_value, b_value) then
			result[key] = a_value
		else
			error(
				string.format(
					"Conflicting LSP config at %q: existing=%s, incoming=%s",
					key_path,
					vim.inspect(a_value),
					vim.inspect(b_value)
				)
			)
		end
	end

	return result
end

local function require_filetype_config(item)
	local ok, config = pcall(require, item.module)

	if not ok then
		error(string.format("Failed to load filetype config %q: %s", item.module, config))
	end

	return config
end

local capabilities = require("blink.cmp").get_lsp_capabilities()

vim.lsp.config("*", {
	on_attach = on_attach,
	capabilities = capabilities,
})

local lsp_configs = {}
local formatters_by_filetype = {}

for _, item in ipairs(filetype_configs) do
	local filetype = item.filetype
	local config = require_filetype_config(item)

	if config.lsp then
		local server = config.lsp.server

		if not server then
			error(string.format("Missing lsp.server in %q", item.module))
		end

		if not lsp_configs[server] then
			lsp_configs[server] = vim.deepcopy(config.lsp)
		else
			lsp_configs[server] =
				merge_lsp(lsp_configs[server], config.lsp, string.format("%s from %s", server, item.module))
		end

		lsp_configs[server].filetypes =
			vim.list.unique(vim.list_extend(lsp_configs[server].filetypes or {}, { filetype }))
	end

	if config.formatters then
		formatters_by_filetype[filetype] = config.formatters
	end
end

for server, config in pairs(lsp_configs) do
	config.server = nil
	config.filetypes = vim.list.unique(config.filetypes or {})

	vim.lsp.config(server, config)
	vim.lsp.enable(server)
end

local ok, conform = pcall(require, "conform")

if ok then
	conform.formatters_by_ft["*"] = global_formatters

	for filetype, formatters in pairs(formatters_by_filetype) do
		conform.formatters_by_ft[filetype] = formatters
	end
end

local mason_tools = vim.list_extend({}, global_formatters)

for server, _ in pairs(lsp_configs) do
	table.insert(mason_tools, server_to_mason[server] or server)
end

for _, formatters in pairs(formatters_by_filetype) do
	vim.list_extend(mason_tools, formatters)
end

mason_tools = vim.list.unique(mason_tools)

vim.api.nvim_create_user_command("MasonInstallAll", function()
	local registry = require("mason-registry")

	registry.refresh(function()
		local missing = {}

		for _, tool in ipairs(mason_tools) do
			local ok_pkg, pkg = pcall(registry.get_package, tool)

			if ok_pkg and pkg and not pkg:is_installed() then
				table.insert(missing, tool)
			end
		end

		if #missing > 0 then
			vim.notify("Installing: " .. table.concat(missing, ", "), vim.log.levels.INFO)
			vim.cmd("MasonInstall " .. table.concat(missing, " "))
		else
			vim.notify("All Mason tools are already installed.", vim.log.levels.INFO)
		end
	end)
end, {
	desc = "Install all configured LSP/formatters tools via Mason",
})
