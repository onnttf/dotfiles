-- Maps LSP server names (used by |vim.lsp.config()|) to Mason package names
-- where they differ. See |mason-registry|.
local server_to_mason = {
	ts_ls    = "ts-ls",
	json_lsp = "vscode-json-language-server",
	bashls   = "bash-language-server",
}

-- Formatters applied to all filetypes via |conform.nvim|.
local global_formatters = { "codespell" }

-- Per-filetype LSP server and formatter configuration.
--   lsp.server       Server name for |vim.lsp.config()| / |vim.lsp.enable()|.
--   lsp.cmd          Command used to start the server.
--   lsp.root_markers Files/dirs used to detect the project root. |vim.lsp.Config|
--   formatter        Formatter list passed to |conform.nvim|.
local filetype_config = {
	go = {
		lsp       = { server = "gopls", cmd = { "gopls" }, root_markers = { "go.work", "go.mod", ".git" } },
		formatter = { "goimports", "gofumpt" },
	},
	gomod  = { lsp = { server = "gopls" } },
	gowork = { lsp = { server = "gopls" } },
	gotmpl = { lsp = { server = "gopls" } },

	python = {
		lsp = {
			server       = "pyright",
			cmd          = { "pyright-langserver", "--stdio" },
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
						autoSearchPaths       = true,
						useLibraryCodeForTypes = true,
						diagnosticMode        = "openFilesOnly",
					},
				},
			},
		},
	},

	javascript      = {
		lsp = {
			server       = "ts_ls",
			cmd          = { "typescript-language-server", "--stdio" },
			root_markers = { "package.json", "package-lock.json", "yarn.lock", "pnpm-lock.yaml", ".git" },
		},
		formatter = { "prettier" },
	},
	javascriptreact = { lsp = { server = "ts_ls" }, formatter = { "prettier" } },
	typescript      = { lsp = { server = "ts_ls" }, formatter = { "prettier" } },
	typescriptreact = { lsp = { server = "ts_ls" }, formatter = { "prettier" } },

	lua = {
		lsp       = {
			server       = "lua-language-server",
			cmd          = { "lua-language-server" },
			root_markers = { ".git", ".luarc.json", ".luarc.jsonc", "stylua.toml" },
		},
		formatter = { "stylua" },
	},

	json  = {
		lsp       = { server = "json_lsp", cmd = { "vscode-json-language-server", "--stdio" }, root_markers = { ".git" } },
		formatter = { "prettier" },
	},
	jsonc = { lsp = { server = "json_lsp" }, formatter = { "prettier" } },

	yaml = {
		lsp = {
			server       = "yaml-language-server",
			cmd          = { "yaml-language-server", "--stdio" },
			root_markers = { ".git" },
		},
		formatter = { "prettier" },
	},

	bash = {
		lsp       = { server = "bashls", cmd = { "bash-language-server", "start" } },
		formatter = { "shfmt" },
	},
	sh = { lsp = { server = "bashls" }, formatter = { "shfmt" } },
}

-- Deep-merge two LSP configs. List-valued fields are concatenated and deduplicated.
-- Requires nvim 0.12+ for function-typed |vim.tbl_deep_extend()| behavior argument.
local function merge_lsp(a, b)
	return vim.tbl_deep_extend(function(_, va, vb)
		if vim.islist(va) and vim.islist(vb) then
			return vim.list.unique(vim.list_extend(vim.list_extend({}, va), vb))
		end
		return vb
	end, a, b)
end

-- Collect all Mason tool names derived from filetype_config.
local mason_tools = vim.list_extend({}, global_formatters)
for _, cfg in pairs(filetype_config) do
	if cfg.lsp then
		local mason_name = server_to_mason[cfg.lsp.server] or cfg.lsp.server
		table.insert(mason_tools, mason_name)
	end
	if cfg.formatter then
		for _, f in ipairs(cfg.formatter) do
			table.insert(mason_tools, f)
		end
	end
end
mason_tools = vim.list.unique(mason_tools)

-- Auto-install missing Mason tools on startup. |mason-registry|
local function ensure_mason_installed()
	local registry = require("mason-registry")
	registry.refresh(function()
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
end

vim.schedule(ensure_mason_installed)

-- Called on |LspAttach|. Registers buffer-local keymaps conditioned on server
-- capability. All maps use |noremap| and |silent|.
local on_attach = function(client, bufnr)
	local function map(mode, lhs, rhs, desc)
		vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, noremap = true, desc = desc })
	end
	local function supports(method)
		return client:supports_method(method)
	end

	-- Navigation.                                               *gd-lsp* *gD-lsp*
	-- gd  Go to definition.  Overrides |gd| (local declaration).  |vim.lsp.buf.definition()|
	-- gD  Go to declaration. Overrides |gD| (global declaration). |vim.lsp.buf.declaration()|
	if supports("textDocument/definition") then
		map("n", "gd", vim.lsp.buf.definition, "Go to Definition")
	end
	if supports("textDocument/declaration") then
		map("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
	end
	-- |gri|  Go to implementation.  Default mapping since nvim 0.11. |vim.lsp.buf.implementation()|
	-- |grt|  Go to type definition. Default mapping since nvim 0.12. |vim.lsp.buf.type_definition()|
	-- |grr|  List references.       Default mapping since nvim 0.11. |vim.lsp.buf.references()|
	if supports("textDocument/implementation") then
		map("n", "gri", vim.lsp.buf.implementation, "Go to Implementation")
	end
	if supports("textDocument/typeDefinition") then
		map("n", "grt", vim.lsp.buf.type_definition, "Go to Type Definition")
	end
	if supports("textDocument/references") then
		map("n", "grr", vim.lsp.buf.references, "List References")
	end

	-- Hover and signature help.                    *K-lsp-default* *i_CTRL-S-lsp*
	-- K      Show hover documentation. Default mapping since nvim 0.11. |vim.lsp.buf.hover()|
	-- <C-s>  Signature help in Insert mode.        Default mapping since nvim 0.11. |vim.lsp.buf.signature_help()|
	if supports("textDocument/hover") then
		map("n", "K", vim.lsp.buf.hover, "Hover Documentation")
	end
	if supports("textDocument/signatureHelp") then
		map("i", "<C-s>", vim.lsp.buf.signature_help, "Signature Help")
	end

	-- Code actions.                                              *grn* *gra* *grx*
	-- |grn|  Rename symbol.   Default mapping since nvim 0.11. |vim.lsp.buf.rename()|
	-- |gra|  Code action.     Default mapping since nvim 0.11. |vim.lsp.buf.code_action()|
	-- |grx|  Run code lens.   Default mapping since nvim 0.12. |vim.lsp.codelens.run()|
	if supports("textDocument/rename") then
		map("n", "grn", vim.lsp.buf.rename, "Rename Symbol")
	end
	if supports("textDocument/codeAction") then
		map({ "n", "v" }, "gra", vim.lsp.buf.code_action, "Code Action")
	end
	if supports("textDocument/codeLens") then
		map("n", "grx", vim.lsp.codelens.run, "Run Code Lens")
	end

	-- Symbols.                                                        *gO-lsp*
	-- |gO|         List document symbols. Default mapping since nvim 0.11. |vim.lsp.buf.document_symbol()|
	-- <leader>ls   List workspace symbols.                            |vim.lsp.buf.workspace_symbol()|
	if supports("textDocument/documentSymbol") then
		map("n", "gO", vim.lsp.buf.document_symbol, "Document Symbols")
	end

	-- LSP extras (<leader>l*).
	if supports("workspace/symbol") then
		map("n", "<leader>ls", vim.lsp.buf.workspace_symbol, "Workspace Symbols")
	end
	-- Toggle inlay hints for the current buffer. |lsp-inlay_hint|
	if supports("textDocument/inlayHint") then
		map("n", "<leader>lh", function()
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
		end, "Toggle Inlay Hints")
	end
	-- Call hierarchy. |vim.lsp.buf.incoming_calls()| |vim.lsp.buf.outgoing_calls()|
	if supports("callHierarchy/incomingCalls") then
		map("n", "<leader>li", vim.lsp.buf.incoming_calls, "Incoming Calls")
	end
	if supports("callHierarchy/outgoingCalls") then
		map("n", "<leader>lo", vim.lsp.buf.outgoing_calls, "Outgoing Calls")
	end
	-- Type hierarchy (supertypes / subtypes). |vim.lsp.buf.typehierarchy()|
	if supports("textDocument/prepareCallHierarchy") then
		map("n", "<leader>lt", function()
			vim.ui.select(
				{ "supertypes", "subtypes" },
				{ prompt = "Type hierarchy:", kind = "typehierarchy" },
				function(kind)
					if kind then
						vim.lsp.buf.typehierarchy(kind)
					end
				end
			)
		end, "Type Hierarchy")
	end

	-- Incremental selection. nvim 0.12+.                         *v_an* *v_in*
	-- |v_an|  Expand selection outward to the parent treesitter node.
	-- |v_in|  Shrink selection inward to a child treesitter node.
	-- Powered by |lsp-selectionRange| (textDocument/selectionRange).
	if supports("textDocument/selectionRange") then
		map("v", "an", "an", "Select Outer Node")
		map("v", "in", "in", "Select Inner Node")
	end

	-- LSP-based folding. |vim.lsp.foldexpr()|
	-- Auto-closes import blocks on buffer open via |LspNotify|. |vim.lsp.foldclose()|
	if supports("textDocument/foldingRange") then
		vim.wo[0].foldmethod = "expr"
		vim.wo[0].foldexpr   = "v:lua.vim.lsp.foldexpr()"
		vim.api.nvim_create_autocmd("LspNotify", {
			buffer   = bufnr,
			callback = function(ev)
				if ev.data.method == "textDocument/didOpen" then
					vim.lsp.foldclose("imports", vim.fn.bufwinid(bufnr))
				end
			end,
		})
	end

	-- Highlight all references to the symbol under cursor on |CursorHold|.
	-- Requires |'updatetime'|. |vim.lsp.buf.document_highlight()|
	if supports("textDocument/documentHighlight") then
		vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
			buffer   = bufnr,
			callback = vim.lsp.buf.document_highlight,
		})
		vim.api.nvim_create_autocmd("CursorMoved", {
			buffer   = bufnr,
			callback = vim.lsp.buf.clear_references,
		})
	end

	-- Diagnostic navigation. Default mappings since nvim 0.11.  *[d-default* *]d-default*
	-- [d/]d  Jump to prev/next diagnostic. Accepts [count].
	-- [D/]D  Jump to first/last diagnostic in buffer.           *[D-default* *]D-default*
	-- [e/]e  Jump to prev/next error (severity >= ERROR).
	-- [w/]w  Jump to prev/next warning (severity >= WARN).
	map("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end,                            "Previous Diagnostic")
	map("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end,                             "Next Diagnostic")
	map("n", "[D", function() vim.diagnostic.jump({ count = -math.huge, wrap = false }) end,      "First Diagnostic")
	map("n", "]D", function() vim.diagnostic.jump({ count = math.huge,  wrap = false }) end,      "Last Diagnostic")
	map("n", "[e", function()
		vim.diagnostic.jump({ count = -1, severity = { min = vim.diagnostic.severity.ERROR } })
	end, "Previous Error")
	map("n", "]e", function()
		vim.diagnostic.jump({ count = 1, severity = { min = vim.diagnostic.severity.ERROR } })
	end, "Next Error")
	map("n", "[w", function()
		vim.diagnostic.jump({ count = -1, severity = { min = vim.diagnostic.severity.WARN } })
	end, "Previous Warning")
	map("n", "]w", function()
		vim.diagnostic.jump({ count = 1, severity = { min = vim.diagnostic.severity.WARN } })
	end, "Next Warning")

	-- Diagnostic actions (<leader>x*). |vim.diagnostic|
	map("n", "<leader>xo", vim.diagnostic.open_float, "Show Diagnostics")
	map("n", "<leader>xl", vim.diagnostic.setloclist, "Diagnostic Location List")
	map("n", "<leader>xq", vim.diagnostic.setqflist,  "Diagnostic Quickfix List")
	-- Pull workspace diagnostics. nvim 0.12+. |vim.lsp.buf.workspace_diagnostics()|
	if supports("workspace/diagnostic") then
		map("n", "<leader>xw", vim.lsp.buf.workspace_diagnostics, "Workspace Diagnostics")
	end
end

-- Merge per-filetype LSP configs into a server-keyed table, then register and
-- enable each server via |vim.lsp.config()| / |vim.lsp.enable()|.
local capabilities = require("blink.cmp").get_lsp_capabilities()
vim.lsp.config("*", { on_attach = on_attach, capabilities = capabilities })

local lsp_config   = {}
local ft_formatters = {}

for ft, cfg in pairs(filetype_config) do
	if cfg.lsp then
		local server = cfg.lsp.server
		if not lsp_config[server] then
			lsp_config[server] = vim.tbl_deep_extend("force", {}, cfg.lsp)
		else
			lsp_config[server] = merge_lsp(lsp_config[server], cfg.lsp)
		end
		lsp_config[server].filetypes = vim.list_extend(lsp_config[server].filetypes or {}, { ft })
	end
	if cfg.formatter then
		ft_formatters[ft] = cfg.formatter
	end
end

for server, cfg in pairs(lsp_config) do
	cfg.filetypes = vim.list.unique(cfg.filetypes)
	vim.lsp.config(server, cfg)
	vim.lsp.enable(server)
end

-- Register per-filetype formatters with |conform.nvim|.
local ok, conform = pcall(require, "conform")
if ok then
	conform.formatters_by_ft["*"] = global_formatters
	for ft, formatters in pairs(ft_formatters) do
		conform.formatters_by_ft[ft] = formatters
	end
end
