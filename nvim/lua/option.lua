-- [[ Option ]]

-- Define core editor options for a better user experience.
local options = {
	-- General UI
	number = true, -- Show line numbers.
	mouse = "a", -- Enable mouse support in all modes.
	showmode = false, -- Don't show the current mode in the command line.
	signcolumn = "yes", -- Always show the sign column for diagnostics and git signs.
	cursorline = true, -- Highlight the current line.
	scrolloff = 10, -- Keep 10 lines of context above/below cursor.

	-- Indentation & Wrapping
	tabstop = 4, -- Number of spaces a <Tab> in the file counts for.
	shiftwidth = 4, -- Number of spaces for each auto-indent step.
	expandtab = true, -- Use spaces instead of tabs.
	breakindent = true, -- Keep indentation when wrapping lines.
	wrap = false, -- Disable line wrapping by default.

	-- Searching
	ignorecase = true, -- Perform case-insensitive searches.
	smartcase = true, -- Override 'ignorecase' if pattern has uppercase chars.
	incsearch = true, -- Highlight matches as you type.
	hlsearch = true, -- Highlight all matches for current search.

	-- Performance & Responsiveness
	updatetime = 250, -- Decrease update time for plugins like LSP.
	timeoutlen = 300, -- Time (ms) to wait for a mapped sequence.

	-- Splits & Windows
	splitright = true, -- Vertical splits open to the right.
	splitbelow = true, -- Horizontal splits open below.

	-- Whitespace Visibility
	list = true, -- Show whitespace characters.
	listchars = { -- Define symbols for displaying whitespace.
		tab = "» ", -- Tabs appear as "» ".
		trail = "·", -- Trailing spaces appear as "·".
		nbsp = "␣", -- Non-breakable spaces appear as "␣".
	},

	-- Clipboard
	clipboard = "unnamedplus", -- Use the system clipboard for all yank/delete/put operations.

	-- Folding
	foldmethod = "expr", -- Set fold method to "expr".
	foldexpr = "v:lua.vim.treesitter.foldexpr()", -- Use Tree-sitter for folding.
	foldlevelstart = 99, -- Start with all folds open.
	foldenable = true, -- Enable folding.
}

-- Apply the defined options to Neovim.
for k, v in pairs(options) do
	vim.opt[k] = v
end

-- Configure Neovim's built-in diagnostics.
vim.diagnostic.config({
	virtual_text = {
		enabled = true,
	},
})
