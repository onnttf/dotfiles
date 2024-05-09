require("nvim-treesitter.configs").setup({
	ensure_installed = {
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
	},
	-- Autoinstall languages that are not installed
	auto_install = true,
	highlight = {
		enable = true,
		disable = function(lang, buf)
			-- Disable highlighting for large files
			local max_filesize = 100 * 1024 -- Max file size in bytes
			local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf)) -- Get file stats
			if ok and stats and stats.size > max_filesize then -- Check if file size exceeds threshold
				return true -- Disable highlighting
			end
		end,
		additional_vim_regex_highlighting = false, -- Disable additional vim regex highlighting
	},
	indent = { enable = true },
	-- There are additional nvim-treesitter modules that you can use to interact
	-- with nvim-treesitter. You should go explore a few and see what interests you:
	--
	--    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
	--    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
	--    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
	-- incremental_selection = { -- Incremental selection settings
	--     enable = true, -- Enable incremental selection
	--     keymaps = { -- Keymaps for incremental selection
	--         init_selection = "<CR>", -- Keymap for initializing selection
	--         node_incremental = "<CR>", -- Keymap for incremental node selection
	--         node_decremental = "<BS>", -- Keymap for decremental node selection
	--         scope_incremental = "<Tab>" -- Keymap for incremental scope selection
	--     }
	-- }
})
