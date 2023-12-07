-- https://github.com/nvim-treesitter/nvim-treesitter
require("nvim-treesitter.configs").setup({
	-- List of parsers to ensure are installed or "all"
	-- Refer to https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
	ensure_installed = {
		"bash",
		"vim",
		"lua",
		"go",
		"sql",
		"php",
		"javascript",
		"vue",
		"css",
		"json",
		"yaml",
		"markdown",
		"dockerfile",
	},
	highlight = {
		enable = true,
		disable = function(lang, buf)
			-- Disable highlighting for large files (greater than 100 KB)
			local max_filesize = 100 * 1024
			local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
			if ok and stats and stats.size > max_filesize then
				return true
			end
		end,
		-- Enable additional Vim regex highlighting (set to false to improve performance)
		additional_vim_regex_highlighting = false,
	},
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "<CR>",
			node_incremental = "<CR>",
			node_decremental = "<BS>",
			scope_incremental = "<Tab>",
		},
	},
})
