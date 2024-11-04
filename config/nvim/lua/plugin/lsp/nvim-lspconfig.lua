-- Import required modules
local lspconfig = require("lspconfig")
local telescope = require("telescope.builtin")

local filetype_config = require("plugin.lsp.filetype_config")

-- Define autocommand groups
local augroups = {
	lsp_attach = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
	lsp_highlight = vim.api.nvim_create_augroup("lsp-highlight", { clear = false }),
	lsp_detach = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
}

-- Define LSP-related keymaps
local keymap_defs = {
	{ "gd", telescope.lsp_definitions, "[G]oto [D]efinition" },
	{ "gr", telescope.lsp_references, "[G]oto [R]eferences" },
	{ "gI", telescope.lsp_implementations, "[G]oto [I]mplementation" },
	{ "K", vim.lsp.buf.hover, "Hover Documentation" },
	{ "ds", telescope.lsp_document_symbols, "[D]ocument [S]ymbols" },
	{ "rn", vim.lsp.buf.rename, "[R]e[n]ame" },
	{ "ca", vim.lsp.buf.code_action, "[C]ode [A]ction" },
}

-- Set up autocommand for LSP attachment
vim.api.nvim_create_autocmd("LspAttach", {
	group = augroups.lsp_attach,
	callback = function(event)
		-- Helper function to set keymaps
		local map = function(keys, func, desc)
			vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
		end

		-- Apply all defined keymaps
		for _, keymap in ipairs(keymap_defs) do
			map(table.unpack(keymap))
		end

		-- Configure document highlighting if supported by the LSP
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if client and client.server_capabilities.documentHighlightProvider then
			-- Highlight references on cursor hold
			vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
				buffer = event.buf,
				group = augroups.lsp_highlight,
				callback = vim.lsp.buf.document_highlight,
			})

			-- Clear highlights on cursor move
			vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
				buffer = event.buf,
				group = augroups.lsp_highlight,
				callback = vim.lsp.buf.clear_references,
			})

			-- Clean up on LSP detach
			vim.api.nvim_create_autocmd("LspDetach", {
				group = augroups.lsp_detach,
				callback = function(event2)
					vim.lsp.buf.clear_references()
					vim.api.nvim_clear_autocmds({ group = augroups.lsp_highlight, buffer = event2.buf })
				end,
			})
		end
	end,
})

-- Set up mason
require("mason").setup()

-- Configure LSP capabilities
-- local capabilities = vim.tbl_deep_extend("force", vim.lsp.protocol.make_client_capabilities(), require("cmp_nvim_lsp").default_capabilities())

-- Collect tools to be installed
local tool_set = {
	codespell = true,
}

for _, config in pairs(filetype_config) do
	for _, tools in ipairs({ config.lsp, config.formatter, config.linter }) do
		if tools then
			for tool, _ in pairs(tools) do
				tool_set[tool] = true
			end
		end
	end
end

-- Prepare list of tools for installation
local ensure_installed = vim.tbl_keys(tool_set)

-- Set up mason-tool-installer
require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

-- Set up mason-lspconfig
require("mason-lspconfig").setup({
	handlers = {
		function(server_name)
			local server_config = {}
			for _, config in pairs(filetype_config) do
				if config.lsp and config.lsp[server_name] then
					server_config = config.lsp[server_name] or {}
					break
				end
			end
			-- server_config.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server_config.capabilities or {})
			lspconfig[server_name].setup(server_config)
		end,
	},
})
