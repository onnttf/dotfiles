local conform = require("conform")
local filetype_config = require("plugin.lsp.filetype_config")

local function extract_formatters()
	local formatters = {}
	for ft, config in pairs(filetype_config) do
		if config.formatter then
			local ft_formatters = {}
			for formatter, _ in pairs(config.formatter) do
				table.insert(ft_formatters, formatter)
			end
			if #ft_formatters > 0 then
				formatters[ft] = ft_formatters
			end
		end
	end
	return formatters
end

conform.setup({
	default_format_opts = {
		lsp_format = "fallback",
	},
	formatters_by_ft = extract_formatters(),

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
