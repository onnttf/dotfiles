-- Neovim options configuration

-- Editor appearance
local options = {
	number = true,           -- Show line numbers
	mouse = "a",             -- Enable mouse support
	showmode = false,        -- Hide mode display
	signcolumn = "yes",      -- Always show sign column
	cursorline = true,       -- Highlight current line
}

-- Scrolling and movement
options.scrolloff = 8       -- Lines to keep above/below cursor
options.sidescrolloff = 8   -- Columns to keep left/right of cursor

-- Indentation
options.tabstop = 4         -- Spaces per tab
options.shiftwidth = 4      -- Spaces for indentation
options.expandtab = true    -- Use spaces instead of tabs
options.breakindent = true  -- Maintain indent on wrapped lines

-- Text display
options.wrap = false        -- Disable line wrapping
options.list = true         -- Show whitespace characters
options.listchars = {
	tab = "│ ",
	trail = "·",
	nbsp = "␣",
}

-- Search behavior
options.ignorecase = true   -- Case-insensitive search
options.smartcase = true    -- Case-sensitive if capital present
options.incsearch = true    -- Incremental search
options.hlsearch = true     -- Highlight search results

-- Timing
options.updatetime = 250    -- Faster update time
options.timeoutlen = 300    -- Keymap timeout

-- Window splitting
options.splitright = true   -- Vertical splits to the right
options.splitbelow = true   -- Horizontal splits below

-- Apply options
for k, v in pairs(options) do
	vim.opt[k] = v
end

-- System clipboard
if vim.fn.has("clipboard") == 1 then
	vim.opt.clipboard = "unnamedplus"
end

-- Diagnostic configuration
vim.diagnostic.config({
	virtual_text = {
		spacing = 2,
		prefix = "●",
	},
	signs = true,
	underline = true,
	severity_sort = true,
	update_in_insert = false,
})
