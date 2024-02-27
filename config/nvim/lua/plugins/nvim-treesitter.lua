-- https://github.com/nvim-treesitter/nvim-treesitter

-- Importing Treesitter configurations
require("nvim-treesitter.configs").setup({
	-- Treesitter modules configuration
  
	-- Language modules to ensure are installed
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
  
	-- Treesitter highlight settings
	highlight = {
	  enable = true,  -- Enable Treesitter highlight
	  disable = function(lang, buf)
		-- Disable Treesitter for large files
		local max_filesize = 100 * 1024
		local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
		if ok and stats and stats.size > max_filesize then
		  return true
		end
	  end,
  
	  additional_vim_regex_highlighting = false,  -- Disable additional Vim regex highlighting
	},
  
	-- Incremental selection settings
	incremental_selection = {
	  enable = true,  -- Enable incremental selection
	  keymaps = {
		init_selection = "<CR>",         -- Keymap for initializing selection
		node_incremental = "<CR>",       -- Keymap for incremental node selection
		node_decremental = "<BS>",       -- Keymap for decremental node selection
		scope_incremental = "<Tab>",     -- Keymap for incremental scope selection
	  },
	},
  })
  