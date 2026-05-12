-- https://github.com/stevearc/conform.nvim
return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	config = function()
		require("conform").setup({
			format_on_save = function(bufnr)
				-- Skip formatting in node_modules.
				if vim.api.nvim_buf_get_name(bufnr):match("/node_modules/") then return nil end
				return { timeout_ms = 1000, lsp_format = "fallback" }
			end,
		})
		-- Use conform as |'formatexpr'| for |gq| command.
		vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
	end,
}
