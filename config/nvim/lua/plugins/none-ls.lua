-- https://github.com/nvimtools/none-ls.nvim

local null_ls = require("null-ls")

-- Function for LSP formatting
local lsp_formatting = function(bufnr)
	vim.lsp.buf.format({
		filter = function(client)
			-- Use null-ls for formatting
			return client.name == "null-ls"
		end,
		bufnr = bufnr,
	})
end

-- Create an augroup for LSP formatting
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

-- Function called on LSP client attachment
local on_attach = function(client, bufnr)
	if client.supports_method("textDocument/formatting") then
		-- Clear existing autocmds and create BufWritePre autocmd for LSP formatting
		vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })

		vim.api.nvim_create_autocmd("BufWritePre", {
			group = augroup,
			buffer = bufnr,
			callback = function()
				lsp_formatting(bufnr)
			end,
		})
	end
end

-- Setup null-ls with specific sources
require("null-ls").setup({
	sources = {
		-- Code Actions
		-- Completion
		-- Diagnostics
		null_ls.builtins.diagnostics.golangci_lint,
		-- Formatting
		null_ls.builtins.formatting.prettier,
		null_ls.builtins.formatting.gofumpt,
		null_ls.builtins.formatting.goimports,
		null_ls.builtins.formatting.stylua,
		-- Hover
	},
	on_attach = on_attach, -- Attach on LSP client connection
})
