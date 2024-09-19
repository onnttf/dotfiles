local conform = require("conform")

conform.setup({
	formatters_by_ft = {
		lua = { "stylua" },
		-- Run multiple formatters sequentially
		go = { "gofumpt", "goimports" },
		-- Run the first available formatter
		css = { "prettierd", "prettier", stop_after_first = true },
		less = { "prettierd", "prettier", stop_after_first = true },
		html = { "prettierd", "prettier", stop_after_first = true },
		javascript = { "prettierd", "prettier", stop_after_first = true },
		typescript = { "prettierd", "prettier", stop_after_first = true },
		yaml = { "prettierd", "prettier", stop_after_first = true },
		json = { "prettierd", "prettier", stop_after_first = true },
		markdown = { "prettierd", "prettier", stop_after_first = true },
		-- Dynamic formatter selection for Python
		python = function(bufnr)
			return conform.get_formatter_info("ruff_format", bufnr).available and { "ruff_format" }
				or { "isort", "black" }
		end,
		--php = { "php_cs_fixer" },
		-- Default formatters for unspecified filetypes
		["_"] = { "codespell", "trim_whitespace" },
	},

	-- Format on save configuration
	format_on_save = function(bufnr)
		-- Filetypes to ignore for autoformatting
		local ignore_filetypes = {}
		if vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then
			return
		end

		-- Check for global or buffer-local disable flags
		if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
			return
		end

		-- Disable autoformat for files in specific paths
		local bufname = vim.api.nvim_buf_get_name(bufnr)
		if bufname:match("/node_modules/") then
			return
		end

		-- Default format on save behavior
		return { timeout_ms = 500, lsp_format = "fallback" }
	end,

	-- Format after save for slow formatters
	format_after_save = function(bufnr)
		local slow_format_filetypes = {}
		if not slow_format_filetypes[vim.bo[bufnr].filetype] then
			return
		end
		return { lsp_format = "fallback" }
	end,
})
