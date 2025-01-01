local configs = require("nvim-treesitter.configs")

-- List of parsers to ensure are installed
local ensure_installed = {
	"bash",
	"vim",
	"vimdoc",
	"lua",
	"go",
	"php",
	"sql",
	"html",
	"javascript",
	"css",
	"vue",
	"json",
	"yaml",
	"markdown",
	"dockerfile",
}

configs.setup({
	-- A list of parser names
	ensure_installed = ensure_installed,

	-- Automatically install missing parsers when entering buffer
	-- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
	auto_install = true,

	-- Highlighting configuration
	highlight = {
		enable = true,
		-- Use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
		disable = function(lang, buf)
			local max_filesize = 100 * 1024 -- 100 KB
			local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
			if ok and stats and stats.size > max_filesize then
				return true
			end
		end,
		additional_vim_regex_highlighting = false,
	},

	-- Indentation based on treesitter for the = operator.
	-- This is an experimental feature.
	indent = { enable = true },

	-- Uncomment and adjust the following section if you want to use incremental selection
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "<CR>",
			node_incremental = "<CR>",
			node_decremental = "<BS>",
			scope_incremental = "<Tab>",
		},
	},

	textobjects = {
		select = {
			enable = true,
			-- Automatically jump forward to textobj, similar to targets.vim
			lookahead = true,

			keymaps = {
				-- You can use the capture groups defined in textobjects.scm
				["af"] = "@function.outer",
				["if"] = "@function.inner",
				-- You can also use captures from other query groups like `locals.scm`
				["as"] = { query = "@local.scope", query_group = "locals", desc = "Select language scope" },
			},
		},
	},
})
